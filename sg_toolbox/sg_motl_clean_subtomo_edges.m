%% sg_motl_clean_subtomo_edges
% A script to remove subtomograms that are not within the boundaries of
% their original tomograms. Subtomogram positions are taken from a
% motivelist, tomogram sizes from a wedgelist, and a given input boxsize
% defines the size of the subtomograms. A tolerance parameter also allows
% for a few pixels of the subtomogram to fall outside the tomogrm boundary.
%
% WW 08-2018

%% Inputs

% File inputs
input_motl = 'motl_2.star';              % Input motivelist name
wedgelist_name = 'wedgelist.star';          % Input wedgelist name
output_motl = 'motl_eclean_2.star';      % Output motivelist name

% Cleaning parameters
binning = 4;                % Subtomogram binning
boxsize = 50;              % Subtomogram boxsize (pixels)
tolerance = 0;              % Edge tolerance (pixels)
renumber = 1;               % Renumber subtomograms after cleaning. (1 = yes, 0 = no);


%% Initialize

% Read inputs
allmotl = sg_motl_read(input_motl);
n_motls = numel(allmotl);
wedgelist = sg_wedgelist_read(wedgelist_name);
n_tomos = numel(wedgelist);

% Keep arrays per subtomogram
keep_cell = cell(n_tomos,1);



%% Clean by tomogram

% Loop through each tomogram
for i = 1:n_tomos
    
    % Start and end indices
    x1 = 1 + (floor(boxsize/2)+1) - tolerance;
    y1 = x1;
    z1 = x1;
    x2 = floor(wedgelist(i).tomo_x/binning) - floor(boxsize/2) + tolerance;
    y2 = floor(wedgelist(i).tomo_y/binning) - floor(boxsize/2) + tolerance;
    z2 = floor(wedgelist(i).tomo_z/binning) - floor(boxsize/2) + tolerance;
    
    % Tomogram index
    tomo_idx = [allmotl.tomo_num] == wedgelist(i).tomo_num;
    
    % Parse positions
    x = [allmotl(tomo_idx).orig_x] + [allmotl(tomo_idx).x_shift];
    y = [allmotl(tomo_idx).orig_y] + [allmotl(tomo_idx).y_shift];
    z = [allmotl(tomo_idx).orig_z] + [allmotl(tomo_idx).z_shift];
    
    % Determine cutoffs
    x_idx = (x >= x1) & (x <= x2);
    y_idx = (y >= x1) & (y <= y2);
    z_idx = (z >= x1) & (z <= z2);
    keep_cell{i} = x_idx & y_idx & z_idx;
    
end
    
% Concatenated keep index
keep_idx = [keep_cell{:}];
new_motl = allmotl(keep_idx);

% Renumber
if renumber == 1
    new_motl = sg_motl_fill_field(new_motl,'subtomo_num',1:numel(new_motl));
end

% Write output
sg_motl_write(output_motl,new_motl);
disp([num2str(sum(keep_idx)),' out of ',num2str(n_motls),' remaining...']);







