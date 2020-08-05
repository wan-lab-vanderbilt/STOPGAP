function defocii = calculate_local_defocii(p,o,idx,f,motl)
%% calculate_local_defocii
% A function to calculate local defocii value for a given particle. In
% order to calculate this, the wedgelist must contain the tomogram's
% dimensions. The defocus offset is calculated using the particle position
% and it's distance from the tilt-axis (assumed to be on the central 
% Y-axis) and it's distance from the central focal plane (defined as the
% center of mass in Z, i.e. the mean Z value of the allmotl).
%
% WW 01-2018

%% Initialize

% If there are not enough parameters, return mean defocii
if ~all(isfield(o.wedgelist(f.wedge_idx),{'tomo_x','tomo_y','tomo_z','z_shift'}))
    defocii = o.wedgelist(f.wedge_idx).defocus;
    return
end

% Number of tilts
n_tilts = numel(o.wedgelist(f.wedge_idx).tilt_angle);

% Tomogram dimensions
tomo_dims = floor([o.wedgelist(f.wedge_idx).tomo_x;o.wedgelist(f.wedge_idx).tomo_y;o.wedgelist(f.wedge_idx).tomo_z]./p(idx).binning);

% Tomogram centers
tomo_cen = floor(tomo_dims/2)+1;
tomo_cen(3) = tomo_cen(3) - (o.wedgelist(f.wedge_idx).z_shift./p(idx).binning);

% Determine positions
pos = zeros(3,1,'single');
pos(1) = mean(motl.orig_x + motl.x_shift)-tomo_cen(1);
pos(2) = mean(motl.orig_y + motl.y_shift)-tomo_cen(2);
pos(3) = mean(motl.orig_z + motl.z_shift)-(tomo_cen(3)-o.wedgelist(f.wedge_idx).z_shift);



%% Calcualte defocii

% Average defocii
if size(o.wedgelist(f.wedge_idx).defocus,2) == 3
    defocii = mean(o.wedgelist(f.wedge_idx).defocus(:,1:2),2);
elseif size(o.wedgelist(f.wedge_idx).defocus,2) == 1
    defocii = o.wedgelist(f.wedge_idx).defocus;
else
    error('ACHTUNG!!! Invalid number of defocus columns!!!');
end


% Calculate offsets
offsets = zeros(n_tilts,1,'single');

for i = 1:n_tilts
    
    % Calculate rotation matrix
    q = sg_axisangle2quaternion([0,1,0],o.wedgelist(f.wedge_idx).tilt_angle(i));
    rmat = sg_quaternion2matrix(q);
    
    % Rotate positions
    r_pos = rmat*pos;
    
    % Store offset
    offsets(i) = r_pos(3) - f.cen_mass(i);
        
end

% Calculate offset defocii
defocii = defocii - (offsets./10000); % Negative Z is increasing underfocus


