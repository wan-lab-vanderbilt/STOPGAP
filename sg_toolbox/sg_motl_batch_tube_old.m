function sg_motl_batch_tube(tomolist_name,output_name,metadata_type,binning,l_dist,c_dist,padding,subset_list)
%% sg_motl_batch_tube
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
% WW 08-2022


%%%%% DEBUG
tomolist_name = 'tomolist.mat';
output_name = 'pos28_motl_1.star';
metadata_type = 'tube';
binning = 8;
l_dist = 4;
c_dist = 10;
padding = 32;
subset_list = [];

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




%% Inputs

% Input folder
input_folder = '/dors/wan_lab/home/wanw/research/mizuno/startset/';

% Processing list
tnum_list = 'tomos.txt';

% Center file name
cen_file_root = 'clicker';

% Distances
l_dist = 4;    % Distance along tube axis
c_dist = 4;    % Distance around tube axis


% Tomogram dir
tomo_dir = '/dors/wan_lab/home/wanw/research/mizuno/tomo/bin4_novactf/';
digits = 1;
padding = 24;    % Size of the edge boundary for thresholding; any centers within the boundary are removed.

% Output name
output_name = 'allmotl_1.star';

%% Initalize

% Find directores
% all_dir = dir(input_folder);
% dir_idx = [all_dir.isdir] & ~strcmp({all_dir.name},'.')& ~strcmp({all_dir.name},'..');
tomo_num = dlmread([input_folder,'/',tnum_list]);
n_tomos = numel(tomo_num);

% Formatting of tomogram numnber
fmt = ['%0',num2str(digits),'i'];

% Cell to hold motl from each tomogram
tomo_cell = cell(n_tomos,1);


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
m_idx_start = 1;

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
    cen_idx = find(endsWith(tomolist(i).metadata.(metadata_type),'.em'));
    n_cen_files = numel(cen_idx);
    

    % Initialize temporary motl for tomo
    tomo_motl = cell(n_tubes,1);
    
    for j = 1:n_tubes
    
        % Read in center file
        cens = sg_emread([input_folder,'/',num2str(tomo_num,fmt),'/',d(j).name]);
        
        % Parse tube number
        [~,name,~] = fileparts(d(j).name);
        tube_num = str2double(name(numel(cen_file_root)+2:end));
        
        % Generate surface positions
        rad = cens(3,1);    % Parse radius
        [pos,eulers] = sg_motl_generate_tube_function(cens(8:10,:),l_dist,c_dist,rad);
        n_pos = size(pos,2);
        
        % Calculate sub-pixel shifts
        shifts = pos - round(pos);
        
        % Initialize motivelist
        tomo_motl{j} = sg_initialize_motl2(n_pos);
        
        % Fill motivelist
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'motl_idx',m_idx_start:(m_idx_start+n_pos-1));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'tomo_num',tomo_num(i));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'object',j);
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'subtomo_num',m_idx_start:(m_idx_start+n_pos-1));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'orig_x',round(pos(1,:)'));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'orig_y',round(pos(2,:)'));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'orig_z',round(pos(3,:)'));
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'x_shift',shifts(1,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'y_shift',shifts(2,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'z_shift',shifts(3,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'phi',eulers(1,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'psi',eulers(2,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'the',eulers(3,:)');
        tomo_motl{j} = sg_motl_fill_field2(tomo_motl{j},'class',1);
        
        % Increment index
        m_idx_start = m_idx_start + n_pos;
        
    end
    
    % Concatenate and store tomo motl
    tomo_cell{i} = sg_motl_concatenate(false,tomo_motl);
    
    % Threshold list
    tomo_name = [tomo_dir,'/',num2str(tomo_num(i),fmt),'.mrc'];
    tomo_cell{i} = sg_motl_check_tomo_edges(tomo_name,tomo_cell{i},padding);
        
        
end

%% Generate full motivelist

% Concatenate all tomos
allmotl = sg_motl_concatenate(false,tomo_cell);
n_motls = numel(allmotl.motl_idx);

% Write motl
disp([num2str(n_motls),' motivelist entries generated...']);
sg_motl_write2(output_name,allmotl);
        
        





