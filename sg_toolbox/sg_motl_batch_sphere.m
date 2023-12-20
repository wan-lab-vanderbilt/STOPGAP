function sg_motl_batch_sphere(tomolist_name,output_name,metadata_type,binning,p_dist,rand_phi,padding,subset_list)
%% sg_motl_batch_sphere
% A function to batch generate motivelists for a set of spheres. Input data
% is parsed from a TOMOMAN tomolist and metadata type.
%
% The metadata subfolder should contain .em files containg sphere centers
% and radii, as defined by Kun Qu's "pick particle" Chimera plugin. 
%
% "binning" is the binning of the input files
%
% "p_dist" is the inter-particle distance on the sphere surface.
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

% % % % % DEBUG
% tomolist_name = '/hd1/wwan/2022_embo-course/hiv_subset/tomo/tomolist.mat';
% output_name = 'allmotl_1.star';
% metadata_type = 'sphere';
% binning = 8;
% p_dist = 3.5;
% rand_phi = true;
% padding = 16;
% subset_list = 'subset_list.txt';

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


%% Generate spheres for each tomogram
% Subtomogram number counter
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
    for j = 1:n_cen_files
        cen_name = [tomolist(i).stack_dir,'metadata/',metadata_type,'/',tomolist(i).metadata.(metadata_type){cen_idx(j)}];
        cen_cell{j} = sg_emread(cen_name);
    end
    
    % Concatenate centers
    cens = [cen_cell{:}];
    n_spheres = size(cens,2);
    
    
    % Initialize motl cell for tomogram
    sphere_cell = cell(n_spheres,1);
    
    % Generate a motl for each sphere
    for j = 1:n_spheres
        % Calculate sphere
        temp_motl = sg_motl_sphere_function(cens(8:10,j), cens(3,j), p_dist,rand_phi);
        n_temp_motl = numel(temp_motl.motl_idx);
        % Fill subtomo_num
        temp_motl.subtomo_num = int32(subtomo_num:(subtomo_num + n_temp_motl-1))';
        % Increment counter
        subtomo_num = subtomo_num + n_temp_motl;
        % Fill object number
        temp_motl.object = ones(size(temp_motl.object),'int32').*j;
        % Store motl
        sphere_cell{j} = temp_motl;
    end
    
    % Concatenate and fill other fields
    tomo_cell_idx(i) = true;
    tomo_cell{i} = sg_motl_concatenate(false,sphere_cell);
    tomo_cell{i}.tomo_num = ones(size(tomo_cell{i}.tomo_num),'int32').*tomolist(i).tomo_num;
    
    % Threshold list
    dims = tm_parse_tomogram_dimensions(tomolist(i),binning);
    tomo_cell{i} = sg_motl_check_tomo_edges(dims,tomo_cell{i},padding);
    
end

% Remove empty cells
tomo_cell = tomo_cell(tomo_cell_idx);

% Concatenate motl
allmotl = sg_motl_concatenate(false,tomo_cell);
n_motls = numel(allmotl.motl_idx);

% Fill remaining fields
allmotl.motl_idx = int32(1:n_motls)';
allmotl.subtomo_num = int32(1:n_motls)';
allmotl.class = ones(n_motls,1,'int32');


% Write motl
disp([num2str(n_motls),' motivelist entries generated...']);
sg_motl_write2(output_name,allmotl);






