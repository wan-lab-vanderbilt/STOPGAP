function new_motl = sg_motl_check_tomo_edges(tomo_info,motl,padding)
%% sg_motl_check_tomo_edges
% Remove motl entries outside the boundaries of a tomogram edges. Padding
% defines how far from the tomogram edges to set the boundaries. 
%
% Information on tomo dimension can be given in two ways. If tomo_info is a
% string, it is assumed to be a tomogram filenanme; the dimensions will be
% parsed from the file header. If tomo_info is an array with 3 numbers,
% these will be taken as the dimensions.
%
% WW 08-2022

%% Check check

if numel(padding)==1
    padding = [padding,padding,padding];
elseif numel(padding) == 2
    error('ACHTUNG!!! Padding must be either 1 or 3 numbers!!!');
end

% Check motl type
motl = sg_read_convert_motl(motl);
r_type = sg_motl_check_read_type(motl);

%% Clean it up!

% Calculate staring boundaries
x1 = 1 + padding(1);
y1 = 1 + padding(2);
z1 = 1 + padding(3);

% Parse end boundaries
if ischar(tomo_info)
    
    % Get tomogram header
    header = sg_read_mrc_header(tomo_name);

    % Calculate boundaries
    x2 = header.nx - padding(1) - 1;
    y2 = header.ny - padding(2) - 1;
    z2 = header.nz - padding(3) - 1;    
    
elseif isnumeric(tomo_info) && (numel(tomo_info) == 3)
    
    % Calculate boundaries
    x2 = tomo_info(1) - padding(1) - 1;
    y2 = tomo_info(2) - padding(2) - 1;
    z2 = tomo_info(3) - padding(3) - 1;  
        
else
    error('ACHTUNG!!! invalid input tomo_info!!!');
end

% Find cutoffs
x_idx = (motl.orig_x >= x1) & (motl.orig_x <= x2);
y_idx = (motl.orig_y >= y1) & (motl.orig_y <= y2);
z_idx = (motl.orig_z >= z1) & (motl.orig_z <= z2);
idx = x_idx & y_idx & z_idx;

% Return cleaned motl
motl = sg_motl_parse_type2(motl,idx);
if r_type == 1
    new_motl = sg_motl_convert_type2_to_type1(motl);
else
    new_motl = motl;
end



