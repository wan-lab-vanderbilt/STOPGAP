function sg_motl_clean_by_local_geometry(input_motl_name,cmm_name,boxsize,output_motl_name,d_cut,tolerance)
%% sg_motl_clean_by_local_geometry
% Clean a motivelist according to its local geometry, i.e. based on the
% positions of neighboring particles. Using something like a neighbor plot
% or the subtomogram average, place a series of points at the center of the
% neighboring subunits using the Chimera volume tracer and save as a .cmm
% file; this is the "neighbor geometry". This will be used to calculate a
% set of translational vectors between the central subunit and the expected
% neighbors. 
%
% For each entry in the motivelist, the input geometry vectors wil be
% rotated and translated into the entry's reference frame. it will then
% determine whether the motivelist contains a neighbor at each position,
% within a given distance cutoff. If all neighbors are found, minus a given
% tolerance, then it will remain in the dataset; otherwise, it is removed. 
%
% input_motl_name: name of the input motivelist
% cmm_name: name of the .cmm file with the neighbor positions
% ref_boxsize: Boxsize of the reference. Used to determine center for geometry array.
% output_motl_name: name of the output motivelist
% d_cut: distiance cutoff for a neighbor match
% tolerance: number of missing neighbors to tolerate. 0 means all neighbors must be present
% clean_by_object: only search for neighbors from the same object (e.g.
% from the same tube). This requires the object numbers to be properly
% filled.
%
% WW 08-2023

%%%% DEBUG
% input_motl_name = 'allmotl_10.star';
% cmm_name = 'geometry.cmm';
% boxsize = 64;
% output_motl_name = 'allmotl_gclean_10.star';
% d_cut = 3; 
% tolerance = 0;


%% Initialize

% Read input motl
motl = sg_motl_read2(input_motl_name);
n_motls = numel(motl.motl_idx);

% Parse objects
obj_table = sg_object_list2(motl)';
n_obj = size(obj_table,1);

% Shift geometry positions with respect to center of box
cen = floor(boxsize/2)+1;

% Read cmm file
cmm = sg_cmm_read(cmm_name);

% Parse geometry positions
geom = cat(1,[cmm.x],[cmm.y],[cmm.z])-cen;
n_geom = size(geom,2);



% Index for positions to keep
keep_idx = false(n_motls,1);

%% Loop through and clean

for i = 1:n_obj
    disp(['Geometric cleaning tomogram ',num2str(obj_table(i,1)),' object ',num2str(obj_table(i,2)),'...']);
    
    
    % Parse object
    obj_idx = find((motl.tomo_num == obj_table(i,1)) & (motl.object ==  obj_table(i,2)));        
    n_temp_motl = numel(obj_idx);
    
    % Parse positions
    pos = cat(1,(motl.orig_x(obj_idx) + motl.x_shift(obj_idx))',...
                (motl.orig_y(obj_idx) + motl.y_shift(obj_idx))',...
                (motl.orig_z(obj_idx) + motl.z_shift(obj_idx))');
            
    % Parse eulers
    phi = motl.phi(obj_idx);
    psi = motl.psi(obj_idx);
    the = motl.the(obj_idx);
    
    
    % Loop through subunits
    c = 1;
    for j = 1:n_temp_motl
        
        % Match array
        matches = zeros(n_geom,1);
        
        % Loop through geometries
        for k = 1:n_geom
            
            % Generate rotation matrix
            rmat = sg_euler2matrix(phi(j),psi(j),the(j));
            
            % Rotate vector
            rot_geom = round(rmat*geom(:,k));
            
            % Shift vector
            shift_geom = rot_geom + pos(:,j);
            
            % Calculate pairwise distances
            dist = sg_pairwise_dist(shift_geom,pos);
            
            % Check for threshold between closest point
            if min(dist) <= d_cut
                matches(k) = true;
            end

        end
        
        % Check number of matches against tolerance
        if sum(matches) >= (n_geom - tolerance)
            keep_idx(obj_idx(j)) = true;
        end
            
        % Check progress
        if c == floor(n_temp_motl/10)
            disp([num2str(j),' out of ',num2str(n_temp_motl),' positions processed...']);
            c = 1;
        else
            c = c+1;
        end
        
    end
    
    disp(['Tomogram ',num2str(obj_table(i,1)),' object ',num2str(obj_table(i,2)),' cleaned!!! ',num2str(sum(keep_idx(obj_idx))),' out of ',num2str(n_temp_motl),' remaining...']);
end

%% Save new motl

% Crop motl
new_motl = sg_motl_crop_type2(motl,keep_idx);

% Save motl
sg_motl_write2(output_motl_name,new_motl);

disp(['All objets cleaned... ',num2str(sum(keep_idx)),' out of ',num2str(n_motls),' remaining...']);




