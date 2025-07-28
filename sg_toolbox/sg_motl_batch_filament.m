function sg_motl_batch_filament(tomolist_name,motl_name,radlist_name,metadata_type,binning,l_dist,phi_angle,padding,subset_list)
%% sg_motl_batch_filament
% A function to batch generate motivelists for a set of tubes. Input data
% is parsed from a TOMOMAN tomolist and metadata type.
%
% The metadata subfolder should contain .em files, each containg tube 
% centers and radii, as defined by Kun Qu's "pick particle" Chimera plugin. 
%
% "binning" is the binning of the input files
%
% "l_dist" is the inter-particle along the length of the tube.
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
% WW 08-2022


% %%%%% DEBUG
% tomolist_name = 'tomolist.mat';
% motl_name = 'pos28_motl_1.star';
% radlist_name = 'pos28_motl_1_rad.txt';
% metadata_type = 'tube';
% binning = 8;
% l_dist = 4;
% phi_angle = 'random';
% padding = 32;
% subset_list = [];

%% Check check

% Check for subset list
if nargin < 8
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
tomo_cell = cell(n_tomos,1);
tomo_cell_idx = false(n_tomos,1);

% Cell to hold radii for each tomogram
rad_cell = cell(n_tomos,1);

%% Generate spheres for each tomogram
subtomo_num = 1;

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
    n_tubes = t-1;
    
    
    

    % Initialize temporary motl for tomo
    tube_cell = cell(n_tubes,1);
    
    % Initialize temporary array for radii
    tube_rad = zeros(n_tubes,3);
    tube_rad(:,1) = tomolist(i).tomo_num;
    
    for j = 1:n_tubes
    
        % Parse tube motivelist
        tube_idx = cens(2,:) == j;
        tube_cens = cens(:,tube_idx);                
        
        % Parse and store radius
        tube_rad(j,2) = j;
        tube_rad(j,3) = tube_cens(3,1);    
        
        % Generate surface positions        
%         temp_motl = sg_motl_generate_tube_function(cens(8:10,:),l_dist,c_dist,tube_rad(j));
        temp_motl = sg_motl_generate_filament_function(cens(8:10,:),l_dist,phi_angle);

        n_temp_motl = numel(temp_motl.motl_idx);
        
        % Fill subtomo_num
        temp_motl.subtomo_num = int32(subtomo_num:(subtomo_num + n_temp_motl-1))';
        % Increment counter
        subtomo_num = subtomo_num + n_temp_motl;
        % Fill object number
        temp_motl.object = ones(size(temp_motl.object),'int32').*j;
        % Store motl
        tube_cell{j} = temp_motl;
        
%         %%% DEBUG
%         debug_em = zeros(20,n_pos);
%         debug_em(4,:) = 1:n_pos;
%         debug_em(8:10,:) = cat(1,temp_motl.orig_x',temp_motl.orig_y',temp_motl.orig_z');
%         debug_em(11:13,:) = cat(1,temp_motl.x_shift',temp_motl.y_shift',temp_motl.z_shift');
%         debug_em(17:19,:) = cat(1,temp_motl.phi',temp_motl.psi',temp_motl.the');
%         sg_emwrite('debug.em',debug_em);
        

        
    end
    
    % Concatenate and fill other fields
    tomo_cell_idx(i) = true;
    tomo_cell{i} = sg_motl_concatenate(false,tube_cell);
    tomo_cell{i}.tomo_num = ones(size(tomo_cell{i}.tomo_num),'int32').*tomolist(i).tomo_num;
    
    % Store radii
    rad_cell{i} = tube_rad;

    % Threshold list
    dims = tm_parse_tomogram_dimensions(tomolist(i),binning);
    tomo_cell{i} = sg_motl_check_tomo_edges(dims,tomo_cell{i},padding);
    
%     % Concatenate and store tomo motl
%     tomo_cell{i} = sg_motl_concatenate(false,tomo_motl);
%     
%     % Threshold list
%     tomo_name = [tomo_dir,'/',num2str(tomo_num(i),fmt),'.mrc'];
%     tomo_cell{i} = sg_motl_check_tomo_edges(tomo_name,tomo_cell{i},padding);
        
        
end

%% Generate full motivelist

% Remove empty cells
tomo_cell = tomo_cell(tomo_cell_idx);
rad_cell = rad_cell(tomo_cell_idx);

% Concatenate all tomos
allmotl = sg_motl_concatenate(false,tomo_cell);
n_motls = numel(allmotl.motl_idx);

% Fill remaining fields
allmotl.motl_idx = int32(1:n_motls)';
allmotl.subtomo_num = int32(1:n_motls)';
allmotl.class = ones(n_motls,1,'int32');

% Write motl
disp([num2str(n_motls),' motivelist entries generated...']);
sg_motl_write2(motl_name,allmotl);
        
% Write radii list
radii = vertcat(rad_cell{:});  % Concatenate radii
dlmwrite(radlist_name,radii);






