function motl = sg_motl_points_on_surface_function(surf_vol,c_level,p_dist)
%% sg_motl_points_on_surface_function
% A function for generating a randomly distributed set of ponts on a
% surface. This requires an input surface volume, the contour level for
% defining the surface edge, and the distance between points.
%
% The returned motivelist will contain angles defining the normal to the
% convex surface; e.g. point from the center of a sphere. The in-plane
% angles are randomized. 
%
% WW 01-2019

%% Generate surface

disp('    Generating surface vertices...');
surf = isosurface(surf_vol,c_level);       % Determines vertices coordinates for all pixels  on surface with a specified contour level
n_vert = size(surf.vertices,1);


%% Find vertices with given distance threshold
disp('    Distance thresholding vertices...');

% Vertices to keep
k_idx = true(n_vert,1);

% Randomize order of vertices to consider
v_idx = randperm(n_vert);

% Loop through all verices
for i = v_idx
    
    % If vertex is still in dataset
    if k_idx(i)
        
        % Parse position of current vertex
        v_pos = surf.vertices(i,:);
        
        % Determine non-self remaining indices
        temp_idx = true(n_vert,1); temp_idx(i) = false; % Exclude current point
        temp_idx = k_idx & temp_idx;
        
        % Calcuate distances
        temp_dist = sg_pairwise_dist(v_pos',surf.vertices(temp_idx,:)');
        
        % Find particles to remove
        cut_idx = temp_dist >= p_dist;
        k_idx(temp_idx) = cut_idx;
        
    end
end

% Number of remaining positions
n_pos = sum(k_idx);



%% Calculate angles


% Find the normal points of the isosurface vertices
disp('    Calculating normal vectors...');
normals = isonormals(surf_vol,surf.vertices(k_idx,:));

% Parse positions (Fortan/C row/column flip)
x = round(surf.vertices(k_idx,2));
dx = surf.vertices(k_idx,2) - x;
y = round(surf.vertices(k_idx,1));
dy = surf.vertices(k_idx,1) - y;
z = round(surf.vertices(k_idx,3));
dz = surf.vertices(k_idx,3) - z;

% Calculate angles (Fortan/C row/column flip)
disp('    Calculating angles...')
the = atan2d(sqrt(normals(:,2).^2+normals(:,1).^2),normals(:,3));
psi  = 90 + atan2d(normals(:,1),normals(:,2));
phi = rand(n_pos,1).*360;




%% Generate motivelist

% Initialize motl
disp('    Generating motivelist...')
motl = sg_initialize_motl(n_pos);
motl = sg_motl_fill_field(motl,'orig_x',x);
motl = sg_motl_fill_field(motl,'orig_y',y);
motl = sg_motl_fill_field(motl,'orig_z',z);
motl = sg_motl_fill_field(motl,'x_shift',dx);
motl = sg_motl_fill_field(motl,'y_shift',dy);
motl = sg_motl_fill_field(motl,'z_shift',dz);
motl = sg_motl_fill_field(motl,'phi',phi);
motl = sg_motl_fill_field(motl,'psi',psi);
motl = sg_motl_fill_field(motl,'the',the);
motl = sg_motl_fill_field(motl,'subtomo_num',1:n_pos);
motl = sg_motl_fill_field(motl,'halfset','A');
motl = sg_motl_fill_field(motl,'score',0);



















