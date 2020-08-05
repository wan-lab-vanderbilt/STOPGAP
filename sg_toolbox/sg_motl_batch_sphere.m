%% sg_motl_batch_sphere
% A function to batch generate motivelists for a set of spheres. 
%
% The input folder should contain a subfolder for each tomogram; each
% folder should be named after the tomogram number. Within each folder
% there should be a single .em file containing sphere centers and radii, as
% defined by Kun Qu's "pick particle" Chimera plugin. 
% 
% Points can also be thresholded with respect to tomogram boundaries.
%
% WW 07-2018

%% Inputs

% Input folder
input_folder = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/hempelmann/subtomo/startset/';

% Center file name
cen_filename = 'single_vesicle.em';

% Distance between points
p_dist = 3;

% Randomize phi
rand_phi = 1;   % Randomize phi angles (1 = yes, 0 = no)

% Tomogram dir
tomo_dir = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/hempelmann/tomos/bin8/';
digits = 1;
padding = 12;    % Size of the edge boundary for thresholding; any centers within the boundary are removed.

% Output name
output_name = 'allmotl_1.star';

%% Initalize

% Find directores
all_dir = dir(input_folder);
dir_idx = [all_dir.isdir] & ~strcmp({all_dir.name},'.')& ~strcmp({all_dir.name},'..');
d_names = {all_dir(dir_idx).name};
n_tomos = numel(d_names);

% Parse numeric format for tomogram names
nfmt = ['%0',num2str(digits),'i'];

% Cell to hold motl from each tomogram
tomo_cell = cell(n_tomos,1);

%% Generate spheres for each tomogram

% Loop through tomograms
for i = 1:n_tomos
    
    % Read in center file
    cens = sg_emread([input_folder,'/',d_names{i},'/',cen_filename]);
    n_spheres = size(cens,2);
    
    % Initialize motl cell for tomogram
    sphere_cell = cell(n_spheres,1);
    
    % Generate a motl for each sphere
    for j = 1:n_spheres
        % Calculate sphere
        temp_motl = sg_motl_sphere_function(cens(8:10,j), cens(3,j), p_dist,rand_phi);
        % Fill object number
        temp_motl = sg_motl_fill_field(temp_motl,'object',j);
        % Store motl
        sphere_cell{j} = temp_motl;
    end
    
    % Concatenate and fill other fields
    tomo_cell{i} = cat(1,sphere_cell{:});
    tomo_cell{i} = sg_motl_fill_field(tomo_cell{i},'tomo_num',str2double(d_names{i}));
    
    % Threshold list
    tomo_name = [tomo_dir,'/',num2str(str2double(d_names{i}),nfmt),'.rec'];
    tomo_cell{i} = sg_motl_check_tomo_edges(tomo_name,tomo_cell{i},padding);
    
end

% Concatenate motl
allmotl = cat(1,tomo_cell{:});
n_motls = numel(allmotl);

% Fill remaining fields
allmotl = sg_motl_fill_field(allmotl,'subtomo_num',1:n_motls);
allmotl = sg_motl_fill_field(allmotl,'halfset','A');
allmotl = sg_motl_fill_field(allmotl,'score',0);
allmotl = sg_motl_fill_field(allmotl,'class',1);


% Write motl
disp([num2str(n_motls),' motivelist entries generated...']);
sg_motl_write(output_name,allmotl);






