function motl = sg_motl_generate_filament_function(points,l_dist, phi_angle)
%% sg_motl_generate_filament_function
% A function for generating a set of points along a spline. Cone angle is
% determined by filament vector, but phi is arbitrary.
%
% WW 11-2022


%% Check check

% Check phi angle type
if ischar(phi_angle)
    if ~strcmpi(phi_angle,'random')
        error('ACHTUNG!!! phi_angle must either be "random" or a pair of numerical values for [offset,rotation]!!!');
    end
    phi_type = 'random';
else
    if numel(phi_angle) ~= 2
        error('ACHTUNG!!! phi_angle must either be "random" or a pair of numerical values for [offset,rotation]!!!');
    end
    phi_type = 'numeric';
end

        

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
frac_dist = ceil(total_dist/l_dist);  

% Steps as fraction of input points
steps = 1:((n_points-1)/frac_dist):n_points;

% Evaulate spline points
Ft = ppval(F,steps);
n_spline = size(Ft,2);



% %% Generating ring
% 
% % Determine integral number of points around circumference of tube
% n_ang_steps = floor((2*pi*radius)/c_step);
% if mod(n_ang_steps,2)
%     n_ang_steps = n_ang_steps + 1;    % Make sure steps are even... no reason, just OCD
% end
% 
% 
% % Determine arc angle in radians
% angle = (2*pi)/n_ang_steps;
% 
% % Calcualte circle points
% circ_theta = 0:angle:((2*pi)-angle);
% [cx,cy] = pol2cart(circ_theta,repmat(radius,[1,n_ang_steps]));
% circle = cat(1,cx,cy);
% n_circ_steps = size(circle,2);



%% Generate new tube motl

% Initialze motl
positions = zeros(3,n_spline);
eulers = zeros(3,n_spline);

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
    vec = zeros(3,1);
    vec(1) = Ft(1,s)-Ft(1,s-1);
    vec(2) = Ft(2,s)-Ft(2,s-1);
    vec(3) = Ft(3,s)-Ft(3,s-1);
%     [azi,ele,~]=cart2sph(dx,dy,dz);
    
    % Calcualte PSI angle
    psi = 90 + atan2d(vec(2),vec(1));

    % Calculate THE angle
    xy = sqrt((vec(1)^2)+(vec(2)^2));
    the = 90 - atan2d(vec(3),xy);
    
    
    % Store values
    positions(:,i) = Ft(:,i);
    eulers(2,i) = psi;
    eulers(3,i) = the;
    
%     % Set origin to first point
%     origin=repmat([Ft(1,i);Ft(2,i);Ft(3,i)],[1,n_circ_steps]);
%     
%     % Generate 3D circle points
%     pos = cat(1,circle,zeros(1,n_circ_steps));
%     
%     % Apply elevation rotation (as per MATLAB)
%     pos = Ry(pos,-ele-(pi/2));
%     
%     % Apply azimuthal rotation (as per MATLAB)
%     pos = Rz(pos,azi); 
%     
%     % Shift to origin
%     pos = pos + origin;
%     
%     % Calculate range of points
%     s_idx = ((i-1)*n_circ_steps)+1;
%     idx = s_idx:s_idx+n_circ_steps-1;
    
%     % Store positions
%     positions(:,idx) = pos;
%     
%     % Calculate psi and theta
%     x = positions(1,idx) - origin(1);
%     y = positions(2,idx) - origin(2);
%     z = positions(3,idx) - origin(3);
%     eulers(2,idx)  = 90+180/pi.*atan2(y,x); % psi
%     eulers(3,idx)= 180/pi*atan2(sqrt(x.^2+y.^2),z); % theta
%     
%     % Loop through and calculate phi
%     for j = 1:n_circ_steps
%         idx = ((i-1)*n_circ_steps) + j;
%         % Rotate distance vector by psi and theta
%         vec = tom_pointrotate([dx,dy,dz],-eulers(2,idx),0,-eulers(3,idx));
%         % Rotation about the Z-axis
%         eulers(1,idx) = atan2d(vec(2),vec(1));
%     end
    

end


% Calculate phi angles
switch phi_type
    case 'random'
        eulers(1,:) = rand(1,n_spline).*360;        
    case 'numeric'
        eulers(1,:) = ((0:(n_spline-1)).*phi_angle(2)) + phi_angle(1);
        
end

%% Generate motivelist


% Initialize motl
motl = sg_initialize_motl2(n_spline);

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



