%% sg_tm_generate_motl
% Generate a STOPGAP motivelist from the output of a STOPGAP Template
% Matching run. Additional parameters are the score threshold and distance
% threshold.
%
% WW 12-2019

%% Inputs

% Root directory
rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/jonathan/sg_0.7.1/tm_ribo/';

% Parameter file
paramfilename = 'params/tm_param.star';

% Processing indices
proc_idx = 1;  % Which lines of the paramfile to process. Leave blank ([]) to process all indices.


% Output files
output_motl = 'lists/allmotl_pdb_1.star';
split_halfsets=1;   % Split odd/even halfsets

% Threshold parameters
plot_values = true;        % Plot sorted values and take input threshold
threshold = 0.35;

% Particle paramters
d_cut = 8;     % Distance cutoff
cluster_size = [0,0];   % [min,max] values to define a cluster. Setting each parameter to 0 disables it.
n_particles = 0;    % Number of particles to return. Set to 0 to disable.




%% Inititalize

% Read parameter file
p = sg_read_tm_param(rootdir,paramfilename);
n_param = numel(p);

% Check processing index
if isempty(proc_idx)
    proc_idx = 1:n_param;
elseif any(proc_idx>n_param)
    error('ACHTUNG!!! proc_idx contains indices larger than the parameter file!!!');
end
n_idx = numel(proc_idx);



% Initialize cell for motivelists
motl_cell = cell(n_idx,1);



% Check for maximum hit threshold
if n_particles > 0
    max_hits = true;
else
    max_hits = false;
end


%% Process each index

% Loop through each index
m = 1;  % Cell counter
for idx = proc_idx    
    disp(['Processing tomogram number ',num2str(p(idx).tomo_num),'!!!']);
    
    % Refresh paths
    [o,s] = sg_tm_refresh_settings(p,idx);
    
     
    %%%%% Read inputs %%%%% 
    
    % Read smap
    disp('Reading scoring map...');
    smap = sg_volume_read([p(idx).rootdir,'/',o.mapdir,'/',p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext]);
    

    % Read smap
    disp('Reading orientation smap...');
    omap = sg_volume_read([p(idx).rootdir,'/',o.mapdir,'/',p(idx).omap_name,'_',num2str(p(idx).tomo_num),s.vol_ext]);
    
    
    
    % Read template list
    tlist = sg_tm_template_list_read([p(idx).rootdir,'/',o.listdir,'/',p(idx).tlist_name]);
    
    
    % Read template map
    if (numel(tlist) > 1) && check_param(p(idx),'tmap_name')
        multitemp = true;
    else
        multitemp = false;
    end
    if multitemp
        disp('Reading template smap...');
        tmap = sg_volume_read([p(idx).rootdir,'/',o.mapdir,'/',p(idx).tmap_name,'_',num2str(p(idx).tomo_num),s.vol_ext]);
    end
    
    
    % Read angle list
    anglist = csvread([p(idx).rootdir,'/',o.listdir,'/',tlist.anglist_name]);
    
    
    %%%%% Determine threshold %%%%%
    
    if plot_values
        disp('Plotting non-zero CC values...');

        % Find non-zero values
        sval = sort(smap(smap > 0));

        % Plot values
        figure
        plot(sval);
        scatt = gcf;

        % Wait for threshold input
        wait = 0;
        while wait == 0;
            % Wait for user input
            assess_string = input('\nGive me the CC threshold!!!\n','s'); 

            % Empty string
            if isempty(assess_string) 
                fprintf('This is not an answer!!! \n');        
            end

            % Check input is only digits
            isstr = isstrprop(assess_string, 'digit') + isstrprop(assess_string, 'punct') - isstrprop(assess_string,'wspace');
            if (sum(isstr) == numel(assess_string)) && (numel(assess_string) ~= 0)
                threshold = str2double(assess_string);
                wait = 1;
            else
                disp('Unacceptable!!!')

            end
        end


        % Close plot
        if ishandle(scatt)
            close(scatt)
        end
    end


    %%%% Find coordinates %%%%%
    disp('Thresholding scores...');

    % Threshold indices
    t_idx = find(smap(:) >= threshold);

    % Sort voxels by score
    [scores,s_idx] = sort(smap(t_idx),'descend');

    % Sorted indices
    s_ind = t_idx(s_idx);       % Sort 1D indices by score
    n_vox = numel(t_idx);

    % Calculate Cartesian coordinates
    [x,y,z] = ind2sub(size(smap),s_ind);
    pos = cat(1,x',y',z');
    clear x y z t_ind s_ind t_idx 


    %%%%% Distance thresholding %%%%%
    disp('Finding clusters...');
    % tic
    % c_step = n_vox/50;
    % c = c_step;

    % Hit count
    c = 0;

    keep_idx = true(n_vox,1);   % Keep track of what's already been cleared
    hit_idx = false(n_vox,1);   % Keep track of hits in case of number of particles

    for i = 1:n_vox

        if keep_idx(i)

            % Distance
            dist = sg_pairwise_dist(pos(:,i),pos);

            % Find distances within threshold
            d_idx = find(dist <= d_cut);

            % Keep track of clusters
            c_size = numel(d_idx);

            % Check cluster 
            c_check = true;
            if c_size < cluster_size(1)
                c_check = false;
            end
            if cluster_size(2) > 0
                if c_size > cluster_size(2)
                    c_check = false;
                end
            end

            % Clear values
            keep_idx(d_idx) = false;

            % Keep if cluster check passes
            if c_check
                keep_idx(i) = true;
                hit_idx(i) = true;
                c = c+1;
            end


        end

        % Check for early termination
        if max_hits
            if c >= n_particles
                break
            end
        end

    end

    % Remaining positions
    rpos = pos(:,hit_idx);
    n_pos = sum(hit_idx);



    %%%%% Generate motivelist %%%%%
    disp('Generating motivelist...');

    % Initialize motivelist
    temp_motl = sg_initialize_motl2(n_pos);

    % Fill motivliest
    temp_motl.motl_idx = (1:n_pos)';
    temp_motl.tomo_num = repmat(p(idx).tomo_num,n_pos,1);
    temp_motl.object = ones(n_pos,1);
    temp_motl.subtomo_num = (1:n_pos)';
    temp_motl.halfset = repmat({'A'},n_pos,1);
    temp_motl.orig_x = rpos(1,:)';
    temp_motl.orig_y = rpos(2,:)';
    temp_motl.orig_z = rpos(3,:)';
    temp_motl.class = ones(n_pos,1);

    % Fill orientations and scores
    for i = 1:n_pos

        % Parse angle index
        ang_idx = omap(rpos(1,i),rpos(2,i),rpos(3,i));
        temp_motl.phi(i) = anglist(ang_idx,1);
        temp_motl.psi(i) = anglist(ang_idx,2);
        temp_motl.the(i) = anglist(ang_idx,3);

        % Parse score
        temp_motl.score(i) = smap(rpos(1,i),rpos(2,i),rpos(3,i));
        
        % Assign template/class
        if multitemp
            temp_motl.class(i) = tmap(rpos(1,i),rpos(2,i),rpos(3,i));
        end

    end

    % Randomize Eulers by symmetry
    temp_motl = sg_motl_randomize_eulers_by_symmetry(temp_motl,tlist.symmetry);

    
    % Store temporary motivelist
    motl_cell{m} = temp_motl;
    m = m+1;
    
end

% Concatenate motivelists
motl = sg_motl_concatenate(true,motl_cell);
n_motl = numel(motl.subtomo_num);
motl.subtomo_num = int32(1:n_motl)';

% Split halfsets
if split_halfsets
    % Generate halfset cell
    halfset = repmat({'A';'B'},[floor(n_motl/2),1]);
    % Check for odd number
    if mod(n_motl,2)
        halfset = cat(1,halfset,{'A'});
    end
    motl.halfset = halfset;
end
    
    

% Write output
sg_motl_write2(output_motl,motl);




