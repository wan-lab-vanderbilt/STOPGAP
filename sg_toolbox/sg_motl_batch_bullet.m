function sg_motl_batch_bullet(tomolist_name,trunk_name,cone_name,radlist_name,metadata_type,binning,tip_rad,l_dist,c_dist,padding,subset_list)
%% sg_motl_batch_bullet
% A function to batch generate motivelists for a set of bullets. Bullets
% are structures with a conical tip and tube-like trunk. Prime examples of
% bullet-shaped structures are rhabdovirus particles. 
%
% Input data is parsed from a TOMOMAN tomolist and metadata type.
%
% The metadata subfolder should contain .em files, each containg tube 
% centers and radii, as defined by Kun Qu's "pick particle" Chimera plugin.
% For bullets, the first point should be at the top of the tip, second
% point where the tip joins the trunk, and remaining points to define the
% tube-shape of the trunk. 
%
% "binning" is the binning of the input files
%
% "tip_rad" is the radius at the conical tip.
%
% "l_dist" is the inter-particle along the length of the tube.
%
% "c_dist" is the inter-particle along the circumference of the tube.
%
% "rand_phi" randomizes the in-plane phi angles.
%
% "padding" removes positions that are within a certain number of voxels
% from the tomogram edges.
%
% "subset_list" is the name of an input plain-text file for a list of
% tomograms to work on. The list should contain the tomo_num of the
% tomograms to use.
% 
%
% WW 05-2025


% % % %%%% DEBUG
% tomolist_name = 'tomolist.mat';
% trunk_name = 'init/trunk_1.star';
% cone_name='init/cone_1.star';
% radlist_name = 'init/init_radlist.txt';
% metadata_type = 'bullet';
% binning = 8;
% tip_rad = 6;
% l_dist = 5;
% c_dist = 3;
% padding = 16;
% subset_list = [];

%% Check check

% Check for subset list
if nargin < 11
    subset = [];
elseif isempty(subset_list)
    subset = [];
else
    % Read subset list
    subset = dlmread(subset_list);
end


%% Initalize

% Read tomolist
tomolist = tm_read_tomolist([],tomolist_name);
n_tomos = numel(tomolist);

% Cell to hold motl from each tomogram
trunk_tomo_cell = cell(n_tomos,1);
trunk_tomo_cell_idx = false(n_tomos,1);
cone_tomo_cell = cell(n_tomos,1);
cone_tomo_cell_idx = false(n_tomos,1);

% Cell to hold radii for each tomogram
rad_cell = cell(n_tomos,1);

%% Generate spheres for each tomogram
m_idx_start = 1;
trunk_subtomo_num = 1;
cone_subtomo_num = 1;

% Loop through tomograms
for i = 1:n_tomos
    
    % Check processing
    process = true;
    if tomolist(i).skip
        process = false;        
    end
    if ~isempty(subset)
        if ~any(tomolist(i).tomo_num == subset)
            process = false;
        end
    end
    
    % Check if aligned
    if ~tm_check_if_aligned(tomolist(i))
        process = false;
    end
    
    if ~process        
        continue
    end
            
        
    
    % Parse name of stack used for alignment
    switch tomolist(i).alignment_stack
        case 'unfiltered'
            process_stack = tomolist(i).stack_name;
        case 'dose-filtered'
            process_stack = tomolist(i).dose_filtered_stack_name;
        otherwise
            error([p.name,'ACTHUNG!!! Unsuppored stack!!! Only "unfiltered" and "dose-filtered" supported!!!']);
    end        
    [~,stack_name,~] = fileparts(process_stack);
    
    disp(['Generating motivelist for ',stack_name,'...']);
    
    
    % Parse center files
    try
        cen_idx = find(endsWith(tomolist(i).metadata.(metadata_type),'.em'));
    catch
        warning(['ACHTUNG!!! ',stack_name,' contains no .em files!!! Skipping to next tomogram...']);
        continue
    end
    n_cen_files = numel(cen_idx);
    
    % Read in center files
    cen_cell = cell(n_cen_files,1);
    t = 1;  % Tube index counter
    for j = 1:n_cen_files
        
        % Read in center file
        cen_name = [tomolist(i).stack_dir,'metadata/',metadata_type,'/',tomolist(i).metadata.(metadata_type){cen_idx(j)}];
        cen_cell{j} = sg_emread(cen_name);
        
        % Parse tube indices
        tube_id = unique(cen_cell{j}(2,:));
        
        % Update indices within tomogram
        for k = 1:numel(tube_id)
            temp_idx = cen_cell{j}(2,:) == tube_id(k);
            cen_cell{j}(2,temp_idx) = t;
            t = t+1;
        end
        
    end
    
    % Concatenate centers
    cens = [cen_cell{:}];
    n_bullets = t-1;
    
    
    %%%%%%%%%% Calculate motivelists for trunk %%%%%%%%%%

    % Initialize temporary motl for tomo
    trunk_cell = cell(n_bullets,1);
    cone_cell = cell(n_bullets,1);
    
    % Initialize temporary array for radii
    trunk_rad = zeros(n_bullets,3);
    trunk_rad(:,1) = tomolist(i).tomo_num;
    
    for j = 1:n_bullets
    
        % Parse tube motivelist
        trunk_idx = find(cens(2,:) == j);
        trunk_cens = cens(:,trunk_idx);                
        
        % Parse and store radius
        trunk_rad(j,2) = j;
        trunk_rad(j,3) = trunk_cens(3,1);    
        
        
        %%%%%%%%%% Trunk %%%%%%%%%%
        
        % Generate surface positions        
        trunk_temp_motl = sg_motl_generate_tube_function(cens(8:10,trunk_idx(2:end)),l_dist,c_dist,trunk_rad(j,3),[]);
        trunk_n_temp_motl = numel(trunk_temp_motl.motl_idx);
        
        % Fill subtomo_num
        trunk_temp_motl.subtomo_num = int32(trunk_subtomo_num:(trunk_subtomo_num + trunk_n_temp_motl-1))';
        % Increment counter
        trunk_subtomo_num = trunk_subtomo_num + trunk_n_temp_motl;
        % Fill object number
        trunk_temp_motl.object = ones(size(trunk_temp_motl.object),'int32').*j;
        % Store motl
        trunk_cell{j} = trunk_temp_motl;
        
        
        %%%%%%%%%% Cone %%%%%%%%%%
        
        % Generate surface positions        
        cone_temp_motl = sg_motl_generate_cone_function(cens(8:10,trunk_idx(1:2)),l_dist,c_dist,tip_rad,trunk_cens(3,1),[]);
        cone_n_temp_motl = numel(cone_temp_motl.motl_idx);
        
        % Fill subtomo_num
        cone_temp_motl.subtomo_num = int32(cone_subtomo_num:(cone_subtomo_num + cone_n_temp_motl-1))';
        % Increment counter
        cone_subtomo_num = cone_subtomo_num + cone_n_temp_motl;
        % Fill object number
        cone_temp_motl.object = ones(size(cone_temp_motl.object),'int32').*j;
        % Store motl
        cone_cell{j} = cone_temp_motl;
    end
    
    % Concatenate and fill other fields
    trunk_tomo_cell_idx(i) = true;
    trunk_tomo_cell{i} = sg_motl_concatenate(false,trunk_cell);
    trunk_tomo_cell{i}.tomo_num = ones(size(trunk_tomo_cell{i}.tomo_num),'int32').*tomolist(i).tomo_num;
    cone_tomo_cell_idx(i) = true;
    cone_tomo_cell{i} = sg_motl_concatenate(false,cone_cell);
    cone_tomo_cell{i}.tomo_num = ones(size(cone_tomo_cell{i}.tomo_num),'int32').*tomolist(i).tomo_num;
    
    % Store radii
    rad_cell{i} = trunk_rad;

    % Threshold list
    dims = tm_parse_tomogram_dimensions(tomolist(i),binning);
    trunk_tomo_cell{i} = sg_motl_check_tomo_edges(dims,trunk_tomo_cell{i},padding);
    cone_tomo_cell{i} = sg_motl_check_tomo_edges(dims,cone_tomo_cell{i},padding);                
        
        
end

%% Generate full motivelists

% Remove empty cells
trunk_tomo_cell = trunk_tomo_cell(trunk_tomo_cell_idx);
cone_tomo_cell = cone_tomo_cell(cone_tomo_cell_idx);
rad_cell = rad_cell(trunk_tomo_cell_idx);

% Concatenate all tomos
trunk_motl = sg_motl_concatenate(false,trunk_tomo_cell);
trunk_n_motls = numel(trunk_motl.motl_idx);
cone_motl = sg_motl_concatenate(false,cone_tomo_cell);
cone_n_motls = numel(cone_motl.motl_idx);

% Fill remaining fields
trunk_motl.motl_idx = int32(1:trunk_n_motls)';
trunk_motl.subtomo_num = int32(1:trunk_n_motls)';
trunk_motl.class = ones(trunk_n_motls,1,'int32');
cone_motl.motl_idx = int32(1:cone_n_motls)';
cone_motl.subtomo_num = int32(1:cone_n_motls)';
cone_motl.class = ones(cone_n_motls,1,'int32');

% Write motl
disp([num2str(trunk_n_motls),' trunk motivelist entries generated...']);
sg_motl_write2(trunk_name,trunk_motl);
sg_motl_stopgap_to_av3(trunk_name);
disp([num2str(cone_n_motls),' cone motivelist entries generated...']);
sg_motl_write2(cone_name,cone_motl);       
sg_motl_stopgap_to_av3(cone_name);

% Write radii list
radii = vertcat(rad_cell{:});  % Concatenate radii
dlmwrite(radlist_name,radii);






