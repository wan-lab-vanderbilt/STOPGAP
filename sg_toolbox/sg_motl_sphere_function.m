function motl = sg_motl_sphere_function(center, radius, p_dist,rand_phi)
%% sg_motl_sphere_function
% A function to calculate an allmotl consisting of equidistant points on
% the surface of a sphere. 
%
% WW 11-2017

%% Check check

if nargin == 3
    rand_phi = true;
end

%% Calculate sphere angles

% Calculate angular increment
init_angincr = (p_dist/(2*pi()*radius))*360;

% Determine closest integer step angular increment
steps = 180/init_angincr;
angincr = 180/(round(steps));

% Generate theta angles
the = 0:angincr:180;
n_the = numel(the);

% Initilize psi array
pair_array = cell(n_the,1); % Exclude poles
pair_array{1} = [0;0];
pair_array{end} = [0;180];

psi_shift = true;
% Loop through and generate psi angles
for i = 2:(n_the-1)
    
    % Radius of circle
    r = sind(the(i))*radius;
    
    % Circumference
    c = 2*pi*r;
    
    % Number of psi steps
    n_psi_steps = round(c/p_dist);
    psi_incr = 360/n_psi_steps;
    
    % Calculate psi angles
    psi_angles = 0:psi_incr:360;
    psi_angles = psi_angles(1:end-1);
    
    % Rotate alternating psi rings
    if psi_shift
        psi_angles = psi_angles + (psi_incr/2);
        idx = psi_angles > 360;
        psi_angles(idx) = psi_angles(idx) - 360; % Circ shift
        psi_shift = false;
    else
        psi_shift = true;
    end
    
    % Store psi/the pairs    
    pair_array{i} = cat(1,psi_angles,repmat(the(i),[1,numel(psi_angles)]));
end

% Concatenate psi/the pairs
psi_the = [pair_array{:}];
n_motls = size(psi_the,2);

%% Generate motivelist


% Initialize motl
motl = sg_initialize_motl2(n_motls);

% Store eulers
if rand_phi
%     motl = sg_motl_fill_field(motl,'phi',(rand(1,n_motls).*360));
    motl.phi = (rand(1,n_motls).*360);
else 
%     motl = sg_motl_fill_field(motl,'phi',0);
    motl.phi = 0;
end
% motl = sg_motl_fill_field(motl,'psi',psi_the(1,:));
% motl = sg_motl_fill_field(motl,'the',psi_the(2,:));
motl.psi = psi_the(1,:);
motl.the = psi_the(2,:);

% Generate coordinates
coord = zeros(3,n_motls);
for i = 1:n_motls
    % Rotate point on top of sphere
    coord(:,i) = tom_pointrotate([0,0,radius],motl.phi(i),motl.psi(i),motl.the(i))';
end
coord = coord + repmat(center(:),[1,n_motls]);

% Extraction positions
pos = round(coord);
% Shifts
shifts = coord - pos;

% Store coordinates
motl.orig_x = single(pos(1,:)');
motl.orig_y = single(pos(2,:)');
motl.orig_z = single(pos(3,:)');
motl.x_shift = single(shifts(1,:)');
motl.y_shift = single(shifts(2,:)');
motl.z_shift = single(shifts(3,:)');




