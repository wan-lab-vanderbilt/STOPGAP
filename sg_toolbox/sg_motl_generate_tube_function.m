function [positions,eulers] = sg_motl_generate_tube_function(points,l_step,c_step,radius)
%% sg_motl_generate_tube_function
% A function for generating a tubular grid with initial euler angles from a
% set of points along the tube axis. 
%
% WW 06-2018



%% Generating spline fit of filament
n_points = size(points,2);

% Create spline function from clicked points
F = spline((1:n_points),points);

% Calculate total distance along spline
total_dist = 0;
for i = 2:n_points
    d_vec = points(:,i)-points(:,(i-1));
    total_dist = total_dist + sqrt((d_vec(1)^2)+(d_vec(2)^2)+(d_vec(3)^2));
end

% Number of steps along spline
frac_dist = ceil(total_dist/l_step);  

% Steps as fraction of input points
steps = 1:((n_points-1)/frac_dist):n_points;

% Evaulate spline points
Ft = ppval(F,steps);
n_spline = size(Ft,2);



%% Generating ring

% Determine integral number of points around circumference of tube
n_ang_steps = floor((2*pi*radius)/c_step);
if mod(n_ang_steps,2)
    n_ang_steps = n_ang_steps + 1;    % Make sure steps are even... no reason, just OCD
end


% Determine arc angle in radians
angle = (2*pi)/n_ang_steps;

% Calcualte circle points
circ_theta = 0:angle:((2*pi)-angle);
[cx,cy] = pol2cart(circ_theta,repmat(radius,[1,n_ang_steps]));
circle = cat(1,cx,cy);
n_circ_steps = size(circle,2);



%% Generate new tube motl

% Initialze motl
n_pos = n_spline*n_circ_steps;
positions = zeros(3,n_pos);
eulers = zeros(3,n_pos);

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
    origin=repmat([Ft(1,i);Ft(2,i);Ft(3,i)],[1,n_circ_steps]);
    
    % Generate 3D circle points
    pos = cat(1,circle,zeros(1,n_circ_steps));
    
    % Apply elevation rotation (as per MATLAB)
    pos = Ry(pos,-ele-(pi/2));
    
    % Apply azimuthal rotation (as per MATLAB)
    pos = Rz(pos,azi); 
    
    % Shift to origin
    pos = pos + origin;
    
    % Calculate range of points
    s_idx = ((i-1)*n_circ_steps)+1;
    idx = s_idx:s_idx+n_circ_steps-1;
    
    % Store positions
    positions(:,idx) = pos;
    
    % Calculate psi and theta
    x = positions(1,idx) - origin(1);
    y = positions(2,idx) - origin(2);
    z = positions(3,idx) - origin(3);
    eulers(2,idx)  = 90+180/pi.*atan2(y,x); % psi
    eulers(3,idx)= 180/pi*atan2(sqrt(x.^2+y.^2),z); % theta
    
    % Loop through and calculate phi
    for j = 1:n_circ_steps
        idx = ((i-1)*n_circ_steps) + j;
        % Rotate distance vector by psi and theta
        vec = tom_pointrotate([dx,dy,dz],-eulers(2,idx),0,-eulers(3,idx));
        % Rotation about the Z-axis
        eulers(1,idx) = atan2d(vec(2),vec(1));
    end
    

end
