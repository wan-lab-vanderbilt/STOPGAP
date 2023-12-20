function tps_parallel_ps(p,o,s,idx)
%% tps_parallel_ps
% A function to load a subtomogram, filter, mask, and unwrap it. After
% unwrapping, each radial plane is Fourier transformed and their amplitudes
% are summed to calculate a power spectrum.
%
% WW 10-2022

%% Initialize
disp([s.cn,'Calculating tube powerspectra in parallel...']);

% Parse tube radius
tomo_idx = o.radlist(:,1) == p(idx).tomo_num;
tube_idx = o.radlist(:,2) == p(idx).tube_num;
tube_radius = o.radlist((tomo_idx&tube_idx),3);

% Initialize an array with size of box padded by radius on either side
tube_edge = (2*tube_radius) + o.boxsize;

% Initialize volume array to store cylindrical polar slices
r = (tube_edge/2); % Radial slice dimension
a = (tube_edge*2); % Azimuthal angle
% unwrap = zeros(r,a,o.boxsize); % Z-Y-X

% Pasting indices
s1= tube_edge-o.boxsize+1;
e1 = tube_edge;
s2 = ((tube_edge-o.boxsize)/2)+1;
e2 = s2 + o.boxsize - 1;

% Subtomo types
subtomo_types = {'unfilt','filt'};



%% Calculate PS

% Number of particles to process
n_part = o.p_tps_end - o.p_tps_start + 1;

% Loop throught classes
for c = 1:o.n_classes
    
    % Initialize counter
    pc = struct();
    pc = progress_counter(pc,'init',n_part,s.counter_pct);
    
    % Current class
    class = o.classes(c);       
    
    % Initialize amplitude volumes
    amp = struct();
    amp.unfilt = zeros(o.boxsize,a,r);
    amp.filt = zeros(o.boxsize,a,r);
%     amp_count = 1;  % Counter for subtomograms
    
    
    for i = o.p_tps_start:o.p_tps_end
                
        
        % Parse motl entry
        motl_idx = o.allmotl.motl_idx == o.node_tps_motl(i);
        motl = parse_motl(o.allmotl,motl_idx);

        % Determine motl to average
        [top_score,tps_idx] = max(motl.score);
        
        
        % Check class
        switch p(idx).tps_mode
            case 'singleref'
                class_check = true;
            otherwise
                class_check = motl.class(tps_idx) == class;
        end
        
        if class_check        % Nest the loops for the process counter            

            
            % Average based on scoring threshold
            if top_score >= p(idx).score_thresh

                
                
                %%%%% Prepare subtomogram %%%%%
                subtomo = struct();
                
                % Read subtomogram
                subtomo_num = motl.subtomo_num(1);
                subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
                try
                    subtomo.unfilt = read_vol(s,o.rootdir,subtomo_name);
                catch
                    error([s.cn,'ACHTUNG!!! Error reading file ',subtomo_name,'!!!']);
                end
                subtomo.unfilt = (subtomo.unfilt - mean(subtomo.unfilt(:)))./std(subtomo.unfilt(:));    % Normalize

                % Parse parameters
                x = motl.x_shift(tps_idx);
                y = motl.y_shift(tps_idx);
                z = motl.z_shift(tps_idx);
                phi = motl.phi(tps_idx);
                psi = motl.psi(tps_idx);
                the = motl.the(tps_idx);
                
                % Rotate subtomogram
                subtomo.unfilt = sg_rotate_vol(sg_shift_vol(subtomo.unfilt,[-x,-y,-z]),[-psi,-phi,-the],[],'cubic');                
                subtomo.unfilt = (subtomo.unfilt - mean(subtomo.unfilt(:)))./std(subtomo.unfilt(:));    % Renormalize
                
                % Swap X and Z; slices through dimension 3 show cross-sections of the tube surface. NOTE: There is a handedness flip!
                subtomo.unfilt = permute(subtomo.unfilt,[3,2,1]);
                
                % Filter and normalize
                subtomo.filt = real(ifftn(fftn(subtomo.unfilt).*o.bpf));             % Filter subtomo
                subtomo.filt = (subtomo.filt - mean(subtomo.filt(:)))./std(subtomo.filt(:));    % Renormalize
                
                % Apply masks
                subtomo.unfilt = subtomo.unfilt.*o.mask;
                subtomo.filt = subtomo.filt.*o.mask;
                
                
                %%%%% Unwrap subtomogram %%%%%

                % Initialize unwrapping volumes
                unwrap = struct();
                unwrap.unfilt = zeros(r,a,o.boxsize); % Z-Y-X
                unwrap.filt = zeros(r,a,o.boxsize); % Z-Y-X

                
                % Process subtomos
                for j = 1:2     % Loop through unfilt and filt
                    
                    % Unwrap volumes
                    for k = 1:o.boxsize
                        
                        % Initialize slice through tube cross section
                        tube_slice = zeros(tube_edge,tube_edge);

                        % Paste subtomogram cross-sectional slice. Center in y, bottom edge of z.
                        tube_slice(s1:e1,s2:e2) = subtomo.(subtomo_types{j})(:,:,k);

                        % Convert tube_slice to polar coordinates
                        pol_slice = tom_cart2polar(tube_slice);

                        % Move the 0 radian axis to center of array
                        pol_slice = circshift(pol_slice,[0 (a/2)]);

                        % Write layer to volume array
                        unwrap.(subtomo_types{j})(:,:,k) = pol_slice;

                    end
                    
                    % Permute
                    unwrap.(subtomo_types{j}) = permute(unwrap.(subtomo_types{j}),[3,2,1]);
                    
                    % Calculate and sum amplitudes
                    for k = 1:r
                        amp.(subtomo_types{j})(:,:,k)  = amp.(subtomo_types{j})(:,:,k) + abs(ifftshift(fft2(unwrap.(subtomo_types{j})(:,:,k))));
                    end
                    
                end    % Unfilt and filt loop
            end        % Score threshold
        end            % Class check
        
        
        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',n_part,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.cn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_part),[' averaged for class ',num2str(class),'... '],rt_str]);
        end
        
        
    end     % Particle loop
    
    %%%%% Write Output Volumes %%%%%
    disp([s.cn,'Power spectrum calculation of class ',num2str(o.classes(c)),' complete!!! Writing outputs...']);
    
    % Parse output names
    switch p(idx).tps_mode
        case 'singleref'
            unfilt_name = [o.tempdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(o.procnum),s.vol_ext];
            filt_name = [o.tempdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(o.procnum),s.vol_ext];
        otherwise
            unfilt_name = [o.tempdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
            filt_name = [o.tempdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
    end
    
    % Write outputs
    write_vol(s,o,p(idx).rootdir,unfilt_name,amp.unfilt);
    write_vol(s,o,p(idx).rootdir,filt_name,amp.filt);
    
    
end     % Class loop


%% Write outputs

% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_p_tps_',num2str(o.procnum)]);
disp([s.cn,'Parallel calculations completed!!!1!']);









