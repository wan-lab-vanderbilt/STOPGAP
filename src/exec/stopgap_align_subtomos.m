function stopgap_align_subtomos(p, o, idx)
%% stopgap_scan_angles_exact
% A modified version of AV3's scan_angles_exact protocol for subtomogram
% alignment. It has also been re-written as a functon for performing 
% subtomogram alignment on an arbitrary number of refrences. Handling of
% classes and other job parameters are decided by a higher-level manager
% function. The majority of parameters is supplied in the 'p' struct, while
% the majority of input arrays are in the 'o' struct. 
%
% Angular search is performed by evenly sampling a cone of orientation
% space. Angles are composed using quaternion multiplication, but rotations
% are done using convered TOM/AV3 Euler triples. 
%
% Scoring is done using the "Roseman" Fast Local Correlation Function
% (FLCL). For 'noshift', the reference and mask are shifted by the 
% previously determined vector, and a simple Pearson correlation is used.
% In all cases, a wedge mask is applied prior to real-space scoring, making
% use of the "constrained correlation" approach. 
%
% Subtomograms with scores below the threshold have their class set to a 
% negative value. This can be used in subsequest steps, i.e. during
% averaging, to prevent subtomograms below the threshold going into the
% final average.
%
% v1: 11-2017
% v2: 01-2018 - added on-the-fly per-slice wedgemask generation, and
% reference CTF and exposure filtering. 
% v3: Added modules for different scoring functions and the 'alignemnt
% filter'.
%
% WW 02-2018


%% Initialize
global nn


% Struct array for storing filters and local parameters
f = struct();
f.tomo = -1; % Loaded tomogram
% Generate parameters for wedge filter type
switch p(idx).wedgelist_type
    case 'slice'
        
        f.wedge_type = 'slice';
         % Check defocus         
        if ~isfield(o.wedgelist,'defocii') && p(idx).calc_ctf
            error('ACHTUNG!!! Wedgelist has no defocus fields... Calculating CTF is IMPOSSIBLE!!!')        
        elseif isfield(o.wedgelist,'defocii') && p(idx).calc_ctf
            f.calc_ctf = true;
        elseif ~p(idx).calc_ctf
            f.calc_ctf = false;
        end
        % Check dose
        if ~isfield(o.wedgelist,'dose') && p(idx).calc_ctf
            error('ACHTUNG!!! Wedgelist has no dose fields... Calculating exposure filters is IMPOSSIBLE!!!')
        elseif isfield(o.wedgelist,'dose') && p(idx).calc_exposure
            f.calc_exposure = true;
        elseif ~p(idx).calc_exposure
            f.calc_exposure = false;
            
        end
        % Calcualte frequency array
        if f.calc_ctf || f.calc_exposure
            f = generate_frequency_array(p,o,f,idx,'align');
        end

        
    case 'wedge'
        
        f.wedge_type = 'wedge';
        f.calc_ctf = false;
        f.calc_exposure = false;
        
end
f.bin_wedge = zeros(o.boxsize,o.boxsize,o.boxsize);   % Binary wedge
f.rfilt = zeros(o.boxsize,o.boxsize,o.boxsize);   % Reference filter
f.pfilt = zeros(o.boxsize,o.boxsize,o.boxsize);   % Particle filter

% Volume array
v = struct();

% Alignment array
ali = struct();

% Initialize scoring function
[o,v,ali] = score_subtomo_match(p,idx,o,v,'init',f,ali);

%% Perform angular search
disp([nn,'Beginning subtomogram alignment!!!'])

    
% Parse allmotl
switch p(idx).subtomo_mode
    case 'ali_singleref'
        % Parse motl for alignment
        allmotl = o.allmotl(:,o.ali_motl_job_idx);
        allmotl_idx = find(o.ali_motl_job_idx);
    case 'ali_multiclass'
        % Parse motl for class
        allmotl = o.allmotl(:,o.ali_motl_job_idx);
        allmotl_idx = find(o.ali_motl_job_idx);
    case 'ali_multiref'
        % Parse motl for alignment
        allmotl = o.allmotl(:,o.ali_motl_job_idx,o.ali_iclass_idx);
        allmotl_idx = find(o.ali_motl_job_idx);
end
% Local n_motl
n_motls = size(allmotl,2);


% Loop over batch
c = 0;  % Completion counter
out_step = n_motls/5;   % How often to write some output
out_flag = out_step;
for i = 1:n_motls

    % Parse out a single motl
    motl = allmotl(:,i,:);

    % Check if motl should be aligned, based on iclass
    if any(o.ali_motl_idx(:,allmotl_idx(i)))

        
        % Check filters
        f = refresh_filters(p,o,f,idx,motl,'align');


        % Read in subtomogram
        name = sprintf([p(idx).subtomoname,'_%0',num2str(p(idx).subtomozeros),'d.em'],motl(4,1,1));
        v.subtomo = read_em(p(idx).rootdir,name);

        % Prepare subtomogram
        [o,v,ali] = score_subtomo_match(p,idx,o,v,'prep',f,ali);
        


        % Align each reference to subtomogram
        m = 1;  % Counter for the third motl dimension, used for multiref vs multiclass
        for j = 1:o.n_ref

            if o.ali_motl_idx(j,allmotl_idx(i))

                % Parse Euler angles from motl
                phi_old = motl(17,1,m);
                psi_old = motl(18,1,m);
                the_old = motl(19,1,m);

                % Convert old Eulers to quaternions for Euler search
                if strcmp(p(idx).search_type,'euler')
                    q_old = will_euler2quaternion(phi_old,psi_old,the_old); 
                end
                
                % Alignment struct
                ali.score = -2;
                ali.old_shift = motl(11:13,1,m);
                
                % Store reference number
                v.ref_num = j;

                % Score search angles
                for k = 1:o.n_ang

                    % Compose search angle
                    switch p(idx).search_type
                        case 'euler'
                            q_search = will_quaternion_multiply(q_old,o.q_ang{k});  % Compose search quaternion
                            [ali.phi,ali.psi,ali.the] = will_quaternion2euler(q_search);   % Convert quaternion to Euler
                        case 'cone'
                            r = tom_pointrotate([0,0,1],0,o.anglist(2,k),o.anglist(3,k));
                            r = tom_pointrotate(r,0,psi_old,the_old);
                            ali.the = atan2d( sqrt( (r(1)^2) + (r(2)^2) ) , r(3) );
                            ali.psi = atan2d(r(2),r(1))+90;
                            ali.phi = phi_old + o.anglist(1,k);
                    end

                    
                    % Score match
                    [o,v,ali] = score_subtomo_match(p,idx,o,v,'score',f,ali);
    

                end     % End angular search loop


                % Write aligned parameters to motl
                motl(1,1,m) = ali.score;
                motl(11,1,m) = ali.shift(1);
                motl(12,1,m) = ali.shift(2);
                motl(13,1,m) = ali.shift(3);
                motl(17,1,m) = ali.phi_opt;
                motl(18,1,m) = ali.psi_opt;
                motl(19,1,m) = ali.the_opt;

                % Set class based on threshold
                if ali.score > p(idx).threshold  
                    motl(20,1,m) = abs(motl(20,1,m));   % Good particles go to postive class
                else
                    motl(20,1,m) = -abs(motl(20,1,m));  % Bad particles go to negative class
                end

                % Increment counter
                m = m+1;

            end     % End reference alignment check                             
        end         % End reference loop
    end             % End alignment check

    % Write out motl
    motlname = [p(idx).splitmotlname,'_',num2str(allmotl_idx(i)),'_',num2str(p(idx).iteration+1),'.em'];
    write_em(p(idx).rootdir,motlname,motl);

    % Increment completion counter
    c = c+1;
    % Write out progress every ~20% finished
    if c >= out_flag
        disp([nn,'Job progress: ',num2str(c),' out of ',num2str(n_motls),' aligned...']);
        out_flag = out_flag + out_step;
    end

end % End alignment loop

disp([nn,'Subtomogram alignment in iteration ',num2str(p(idx).iteration),' completed!!!1!one!']);

end

