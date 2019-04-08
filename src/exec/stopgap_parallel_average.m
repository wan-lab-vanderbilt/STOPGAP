function stopgap_parallel_average(p,o,idx)
%% stopgap_parallel_average
% A function to generate a weighted average in parallel. The
% parallelization is performed in two steps: a parallel step where a
% number of cores generate partial averages, and a final step that averages
% the parallel averages. 
%
% v1: WW 11-2017
% v2: WW 01-2018 Some bugfixes. Streamlined approach for handling multiple
% volumes. Added support for overriding 'refilename' parameter.
%
% WW 01-2018

%% Generate partial allmotl
global nn
avg_modes = {'avg_singleref', 'avg_multiclass', 'avg_multiref'};


% Determine job parameters
[start_motl, end_motl] = will_job_start_end(o.n_motls, p(idx).n_cores_aver, o.procnum_aver);
n_motls = end_motl-start_motl+1;


% Generate partial motl based on mode
disp([nn,'Preparing partial allmotl...']);
if any(strcmp(p(idx).subtomo_mode,avg_modes))    % For mode without alignment, use old allmotl
    disp([nn,'Using existing allmotl...']);
    
    % Parse allmotl
    allmotl = o.allmotl(:,start_motl:end_motl,:);
    
    % Iteration number
    iter = p(idx).iteration;
    
else    % Generate new partial allmotl following alignment
    disp([nn,'Concatenating a new allmotl...']);
    
    % Iteration number
    iter = p(idx).iteration+1;
    
    % Read first motl to determine size of third dimension
    motlname = [p(idx).splitmotlname,'_',num2str(start_motl),'_',num2str(iter),'.em'];
    temp_motl = read_em(p(idx).rootdir,motlname);
    d3 = size(temp_motl,3);
    
    % Initialize new motl array
    allmotl = zeros(20,n_motls,d3);
    allmotl(:,1,:) = temp_motl;
    
    % Add remaining motls
    m = 2; % Counter
    for i = (start_motl+1):end_motl        
        % Read motl
        motlname = [p(idx).splitmotlname,'_',num2str(i),'_',num2str(iter),'.em'];
        temp_motl = read_em(p(idx).rootdir,motlname);
        % Store motl
        allmotl(:,m,:) = temp_motl;
        m = m+1; % Increment counter
    end
    
    % Write partial motl
    pmotl_name = [p(idx).allmotlname,'_',num2str(iter),'_',num2str(o.procnum_aver),'.em'];
    write_em(p(idx).rootdir,pmotl_name,allmotl);
end



%% Determine parameters for averaging


% Initialize some parameters depending on job type

switch p(idx).subtomo_mode
    case {'ali_singleref','avg_singleref'}
        disp([nn,'Performing single-reference averaging...']);
        
        % Determine subtomograms to averaging into a single reference
        if p(idx).iclass == 0
            avg_idx = true(1,n_motls);
        else
            n_iclass = numel(p(idx).iclass);
            avg_idx = logical(sum(repmat(abs(allmotl(20,:)),[n_iclass,1]) == repmat(p(idx).iclass',[1,n_motls]),1));
        end     
        n_classes = 1;
        
    case {'ali_multiclass','avg_multiclass'}
        disp([nn,'Performing multiclass averaging...']);
        
        % Get classes
        if p(idx).iclass == 0
            classes = unique(abs(allmotl(20,:)));
        else
            classes = intersect(unique(abs(allmotl(20,:))),p(idx).iclass);
        end
        n_classes = numel(classes);
        
        % Index of motls to average (dim1 = classes/refs, dim2 = motls in each class)
        avg_idx = (repmat(abs(allmotl(20,:)),[n_classes,1]) == repmat(classes',[1,n_motls]));
        
    case {'ali_multiref','avg_multiref'}
        disp([nn,'Performing multireference averaging...']);
        
        % Find top classes
        if p(idx).iclass == 0
            classes = squeeze(abs(allmotl(20,1,:)));
        else
            [classes, class_idx] = intersect(abs(allmotl(20,1,:)),p(idx).iclass); % Classes and indices along dim3
            allmotl = allmotl(:,:,class_idx);   % Remove non-included classes
        end
        n_classes = numel(classes);
        
        % Get a 2D grid for 
        [~, top_idx] = max(allmotl(1,:,:),[],3);  % Get top indices
        avg_idx = false(n_classes,n_motls); % Indices for all class (dim1 = classes/refs, dim2 = motls in each class)
        for i = 1:n_motls
            avg_idx(top_idx(i),i) = true;
        end
        
end
    

%% Prepare filters


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
            f = generate_frequency_array(p,o,f,idx,'aver');
        end

        
    case 'wedge'
        
        f.wedge_type = 'wedge';
        f.calc_ctf = false;
        f.calc_exposure = false;
        
end
f.bin_wedge = zeros(o.boxsize,o.boxsize,o.boxsize);   % Binary wedge
f.rfilt = zeros(o.boxsize,o.boxsize,o.boxsize);   % Reference filter
f.pfilt = zeros(o.boxsize,o.boxsize,o.boxsize);   % Particle filter


%% Initalize volumes

% Initialize struct arrays
v = struct();   % For volumes

% Parse parameters
[n, v_fields] = parse_refname_volumes(p,idx,'p_aver');

% Initialize for powerspectrum calculation
if isfield(p(idx),'psfilename')
    if ~strcmp(p(idx).psfilename,'none')
        % Initialize powerspectrum volumes
        v.ps = cell(n_classes,1);
        for i = 1:n_classes
            v.ps{i} = zeros(o.boxsize,o.boxsize,o.boxsize);
        end
        % Read in powerspectrum mask
        v.psmask = read_em(p(idx).rootdir,p(idx).psmaskname);
        % Check that binary wedge is calculated
        if ~any(strcmp(v_fields(1,:),'bin_wedge'))
            v_fields = cat(2,v_fields,{'bin_wedge';'bin_wedge'});
            [ref_path,~,~] = fileparts(n.ref);
            n.bin_wedge = [ref_path,'/bin-wedge'];
        end
    end
end

% Number of volumes
n_vol = size(v_fields,2);

% Initialize volumes
for i = 1:n_vol
    v.(v_fields{2,i}) = cell(n_classes,1);
    for k = 1:n_classes
        v.(v_fields{2,i}){k} = zeros(o.boxsize,o.boxsize,o.boxsize);
    end
end

% Temporary rotation array
temp = struct();

%% Rotate and average volumes


% Sum volumes
for j = 1:n_classes % Loop through classes
    disp([nn,'Starting averaging on class ',num2str(j),' of ',num2str(n_classes),'...']);
    
    c = 0;
    c_step = round(n_motls/10);
    % Loop through subtomograms
    for i = 1:n_motls
        
        % Parse motl
        switch p(idx).subtomo_mode
            case {'ali_multiref','avg_multiref'}
                motl = allmotl(:,i,j);
            otherwise
                motl = allmotl(:,i);
        end
                
        if avg_idx(j,i) && (motl(1) >= p(idx).threshold)

            
            % Refresh filters
            f = refresh_filters(p,o,f,idx,motl,'aver');
            
            % Read subtomogram
            subtomo_name = sprintf([p(idx).subtomoname,'_%0',num2str(p(idx).subtomozeros),'d.em'],motl(4));
            subtomo = read_em(p(idx).rootdir,subtomo_name);
            
            % Filter subtomo
            subtomo = real(ifftn(fftn(subtomo).*ifftshift(f.pfilt)));
            
            % Parse Euler angles
            phi = motl(17,1,1);
            psi = motl(18,1,1);
            the = motl(19,1,1);
            
            % Parse shifts
            shift = motl(11:13,1,1)';
            
            % Shift and rotate subtomo
            rsubtomo = tom_rotate(tom_shift(subtomo,-shift),[-psi,-phi,-the]);            

            % Add subtomo to sum
            v.ref{j} = v.ref{j} + rsubtomo;
            
            
            % Rotate and sum wedges
            for k = 2:n_vol
                temp.(v_fields{1,k}) = tom_rotate(f.(v_fields{1,k}),[-psi,-phi,-the]);
                v.(v_fields{2,k}){j} = v.(v_fields{2,k}){j} + temp.(v_fields{1,k});
            end
            
            % Add amplitudes to powerspectrum
            if isfield(v,'ps')
                amp_subtomo = abs(fftshift(fftn(rsubtomo.*v.psmask)));
                v.ps{j} = v.ps{j} + (amp_subtomo.*temp.bin_wedge);
            end
            
            % Counter
            c = c+1;
            if c >= c_step
                disp([nn,num2str(i),' out of ',num2str(n_motls), 'averaged...']);
                c = 0;
            end
            
        end % End iclass test            
    end % End allmotl loop
    
    
    
    % Write volumes
    switch p(idx).subtomo_mode
        
        case {'ali_singleref','avg_singleref'}
            
            % Write volumes
            for k = 1:n_vol
                name = [n.(v_fields{2,k}),'_',num2str(iter),'_',num2str(o.procnum_aver),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{2,k}){j});
            end     
            
            % Write powerspectra
            if isfield(v,'ps')
                name = [p(idx).psfilename,'_',num2str(iter),'_',num2str(o.procnum_aver),'.em'];
                write_em(p(idx).rootdir,name,v.ps{j});
            end
            
        otherwise
            
            % Write volumes
            for k = 1:n_vol
                name = [n.(v_fields{2,k}),'_',num2str(iter),'-',num2str(classes(j)),'_',num2str(o.procnum_aver),'.em'];
                write_em(p(idx).rootdir,name,v.(v_fields{2,k}){j});
            end 
            
            % Write powerspectra
            if isfield(v,'ps')
                name = [p(idx).psfilename,'_',num2str(iter),'-',num2str(classes(j)),'_',num2str(o.procnum_aver),'.em'];
                write_em(p(idx).rootdir,name,v.ps{j});
            end
            
    end % End writing switch

                   
end % End class loop


% Write checkjob
system(['touch ',p(idx).rootdir,'/',p(idx).checkjobdir,'/stopgap-par-avg_',num2str(o.procnum_aver)]);
disp([nn,'Parallel averaging completed!!!1!']);









