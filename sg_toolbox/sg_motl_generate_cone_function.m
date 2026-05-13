function motl = sg_motl_generate_cone_function(points,l_dist,c_dist,radius1,radius2,helical_step)
%% sg_motl_generate_cone_function
% A function for generating a conical grid with initial euler angles from
% two 3D points. The first is at the tip of the cone while the second is at
% the center of the base. 
%
% Two radius values are requires; one for the radius at the tip and second
% for the radius at the base.
%
% WW 05-2025


%% Check check

if isempty(helical_step)
    helical_step = 0;
end

% Check for 2 points
n_points = size(points,2);
if n_points ~= 2
    error('ACHTUNG!!! Input coordines for cone generation should only be two points!!!')
end

%% Generating spline for cone axis

% Create spline function from clicked points
F = spline([1,2],points);

% Distance between points
d_vec = points(:,1)-points(:,2);
dist = sqrt((d_vec(1)^2)+(d_vec(2)^2)+(d_vec(3)^2));

% Number of steps along spline
frac_dist = ceil(dist/l_dist);  

% Steps as fraction of input points
steps = 1:(1/frac_dist):2;

% Evaulate spline points
Ft = ppval(F,steps);
n_spline = size(Ft,2);

%% Generating rings

% Calculate radii for each layer along cone
rad_step = (radius2-radius1)/n_spline; % Radius change per step
radii = radius1:rad_step:radius2;

% Other arrays
n_ang_steps = zeros(n_spline,1);
circ_theta = cell(n_spline,1);
n_circ_steps = zeros(n_spline,1);

% Calculate rings for each layer
for i = 1:n_spline

    % Determine integral number of points around circumference of tube
    n_ang_steps(i) = floor((2*pi*radii(i))/c_dist);
    if mod(n_ang_steps(i),2)
        n_ang_steps(i) = n_ang_steps(i) + 1;    % Make sure steps are even... no reason, just OCD
    end


    % Determine arc angle in radians
    angle = (2*pi)/n_ang_steps(i);

    % Calcualte circle points
    circ_theta{i} = 0:angle:((2*pi)-angle);
    % [cx,cy] = pol2cart(circ_theta,repmat(radius,[1,n_ang_steps]));
    % circle = cat(1,cx,cy);
    n_circ_steps(i) = numel(circ_theta{i});
    
end



%% Generate cone

% Calculate angular offset for normal to cone surface
d_rad = radius2 - radius1;  % Base of triangle for caculating inner angle
alpha = atand(dist/d_rad);  % Compute inner angle
ang_offset = alpha - 90;    % Add 90 for offset to surface
q2 = sg_axisangle2quaternion([0,1,0],ang_offset);   % Quaternion to apply to eulers


% Total number of positions
n_pos = sum(n_circ_steps);

% Initialze arrays
positions = zeros(3,n_pos);
eulers = zeros(3,n_pos);

% Track helical rotation
helical_rot = 0;

% Position counter
p = 1;

for i = 1:n_spline  % For each pair of points on the spline
    
    % Detemine distances in spherical polar coordinates. THETA is the
    % azimuthal angle, i.e. the angle in the X-Y plane about the Z-axis.
    % PHI is the elevation angle, i.e. the angle from the X-Y plane. 
    
    % For first point
    if i == 1
        s = 2;
    else
        s = i;
    end
    
    % Calculate distance vectors
    dx = Ft(1,s)-Ft(1,s-1);
    dy = Ft(2,s)-Ft(2,s-1);
    dz = Ft(3,s)-Ft(3,s-1);
    [azi,ele,~]=cart2sph(dx,dy,dz);
        
    % Set origin to first point
    origin=repmat([Ft(1,i);Ft(2,i);Ft(3,i)],[1,n_circ_steps(i)]);
    
    % Apply helical rotation
    [cx,cy] = pol2cart(circ_theta{i}+helical_rot,repmat(radii(i),[1,n_ang_steps(i)]));
    circle = cat(1,cx,cy);
    
    % Generate 3D circle points
    pos = cat(1,circle,zeros(1,n_circ_steps(i)));
    
    % Apply elevation rotation (as per MATLAB)
    pos = Ry(pos,-ele-(pi/2));
    
    % Apply azimuthal rotation (as per MATLAB)
    pos = Rz(pos,azi); 
    
    % Shift to origin
    pos = pos + origin;
    
    % Calculate storage indices
    p_idx = p:p+n_circ_steps(i)-1;
    
    % Store positions
    positions(:,p_idx) = pos;
    
    % Calculate psi and theta
    x = positions(1,p_idx) - origin(1);
    y = positions(2,p_idx) - origin(2);
    z = positions(3,p_idx) - origin(3);
    eulers(2,p_idx)  = 90+180/pi.*atan2(y,x); % psi
    eulers(3,p_idx)= 180/pi*atan2(sqrt(x.^2+y.^2),z); % theta
    
    % Loop through and calculate phi
    for j = p_idx
        % Rotate distance vector by psi and theta
        vec = tom_pointrotate([dx,dy,dz],-eulers(2,j),0,-eulers(3,j));
        % Rotation about the Z-axis
        eulers(1,j) = atan2d(vec(2),vec(1));
    end
    
    % Add additional for normal to cone surface
    for j = p_idx        
        
        q1 = sg_euler2quaternion(eulers(1,j),eulers(2,j),eulers(3,j));
        q3 = sg_quaternion_multiply(q1,q2);
        [eulers(1,j),eulers(2,j),eulers(3,j)] = sg_quaternion2euler(q3);
    end
    
    % Increment counters
    helical_rot = helical_rot + helical_step;
    p = p + n_circ_steps(i);
end






%% Generate motivelist


% Initialize motl
motl = sg_initialize_motl2(n_pos);

% Store eulers
motl.phi = single(eulers(1,:))';
motl.psi = single(eulers(2,:))';
motl.the = single(eulers(3,:))';

% Calculate positions and shifts
r_pos = round(positions);
shifts = positions - r_pos;

% Store coordinates
motl.orig_x = single(r_pos(1,:)');
motl.orig_y = single(r_pos(2,:)');
motl.orig_z = single(r_pos(3,:)');
motl.x_shift = single(shifts(1,:)');
motl.y_shift = single(shifts(2,:)');
motl.z_shift = single(shifts(3,:)');


%%%DEBUG
% sg_motl_write2('cone.star',motl);
% sg_motl_stopgap_to_av3('cone.star');

