function f = calculate_tilt_center_of_mass(p,o,f,idx)
%% calculate_tilt_center_of_mass
% Calculate the center of mass for each tilt of a tomogram.
%
% WW 06-2018

%% Parse coordinates

% Parse tomogram index
tomo_idx = o.allmotl.tomo_num == f.tomo;

% Tomogram dimensions
tomo_dims = floor([o.wedgelist(f.wedge_idx).tomo_x;o.wedgelist(f.wedge_idx).tomo_y;o.wedgelist(f.wedge_idx).tomo_z]./p(idx).binning);

% Tomogram centers
tomo_cen = floor(tomo_dims/2)+1;
tomo_cen(3) = tomo_cen(3) - (o.wedgelist(f.wedge_idx).z_shift./p(idx).binning);

% Parse XZ positions
switch o.motl_type
    case {1,2}
        
        % Initialize position array
        n_subtomos = sum(tomo_idx);
        pos = zeros(2,n_subtomos);
        
        % Fill positions
        pos(1,:) = o.allmotl.orig_x(tomo_idx) + o.allmotl.x_shift(tomo_idx);
        pos(2,:) = o.allmotl.orig_y(tomo_idx) + o.allmotl.y_shift(tomo_idx);
        pos(3,:) = o.allmotl.orig_z(tomo_idx) + o.allmotl.z_shift(tomo_idx);
        
    case {3}
        
        %Initialize position array
        n_subtomos = sum(tomo_idx)./o.n_classes;
        pos = zeros(2,n_subtomos);
        
        % Fill positions
        pos(1,:) = mean(reshape((o.allmotl.orig_x(tomo_idx) + o.allmotl.x_shift(tomo_idx)),o.n_classes,n_subtomos),1);  % Calculate average position for each subtomogram
        pos(2,:) = mean(reshape((o.allmotl.orig_y(tomo_idx) + o.allmotl.y_shift(tomo_idx)),o.n_classes,n_subtomos),1);
        pos(3,:) = mean(reshape((o.allmotl.orig_z(tomo_idx) + o.allmotl.z_shift(tomo_idx)),o.n_classes,n_subtomos),1);
end

% Shift to center
pos = pos - repmat(tomo_cen,1,n_subtomos);



%% Rotate coordinates and calculate center of mass

% Parse tilts
tilts = o.wedgelist(f.wedge_idx).tilt_angle;
n_tilts = numel(tilts);

% Center of mass array
f.cen_mass = zeros(n_tilts,1,'single');
cen_x = zeros(n_tilts,1,'single');
cen_y = zeros(n_tilts,1,'single');

for i = 1:n_tilts
    
    % Calculate rotation matrix
    q = sg_axisangle2quaternion([0,1,0],tilts(i));
    rmat = sg_quaternion2matrix(q);
    
    % Rotate positions
    r_pos = rmat*pos;
    
    % Center of mass
    f.cen_mass(i) = mean(r_pos(3,:));
    cen_x(i) = mean(r_pos(1,:));
    cen_y(i) = mean(r_pos(2,:));
    
end


