function sym_filter = sg_symmetrize_filter(filter,symmetry,init_euler)
%% sg_symmetrize_filter
% Apply point group symmetry operator to a filter. Operators follow
% Schoenflies notation. Standard orientations of symmetry operators are
% described elsewhere (doi: 1016/j.jsb.2005.06.001). 
%
% Symmetry types allowed include:
% C[n]    -    n-fold cylic symmetry (i.e. C2 is 2-fold cyclic)
% D[n]    -    n-fold dihedral symmetry (i.e. D4 is 4-fold dihedral)
% T       -    tetrahedral symmetry
% O       -    cuboctahedral symmetry
% I       -    icosahedral symmetry
%
% Volumes can also be symmetrized about an arbitrary orientation using the
% "init_euler" input.
%
% A 'filter' differs from a 'volume' in that a filter is assumed to always
% be centered in the box center, and that the minimum and maximum values
% are thresholded after each rotation.
%
% WW 12-2018

%% Check check

% Check for C1
if strcmpi(symmetry,'c1')
    sym_filter = filter;
    return
end


% Check intial eulers
if nargin == 2
    init_euler = [];
end

% Check minimum arguments
if nargin < 2
    error('ACHTUNG!!! Insuffiient input arguments!!!');
end


%% Determine symmetry angles

switch lower(symmetry(1))
    case 'c'
        c_sym = str2double(symmetry(2:end));
        angles = get_cyclic_angles(c_sym);
    case 'd'
        c_sym = str2double(symmetry(2:end));
        angles = get_dihedral_angles(c_sym);
%     case 't'
%         angles = get_tetrahedral_angles();
    case 'o'
        angles = get_octahedral_angles();
    case 'i'
        angles = get_icosahedral_angles();
    otherwise
        error('ACHTUNG!!! Invalid symmetry operator!!!');
end

% Apply initial orientation
if ~isempty(init_euler)
    angles = combine_angles(angles,init_euler);
end

%% Apply symmetry

% Get min and max values
nz_idx = filter ~= 0;
min_val = min(filter(nz_idx));

% Sum symmetric volumes
sym_filter = sum_rotations(filter,angles);

    
% Divide by number of angles
sym_filter = sym_filter./numel(angles);
sym_filter = sym_filter.*(sym_filter <= 1).*(sym_filter >= (min_val/numel(angles)));



end


    
%% Generate cyclic angles
% Generate Euler angles for cyclic symmetry.
function angles = get_cyclic_angles(n_fold)

% Generate phi angles
phi = linspace(0,360,(n_fold+1));
phi = phi(1:end-1);

% Generate cell array with triplets
angles = cell(n_fold,1);
for i = 1:n_fold
    angles{i} = [phi(i),0,0];
end

end

%% Generate dihedral angles
% Generate Euler angles for diheral symmetry.
function angles = get_dihedral_angles(n_fold)

% Generate phi angles
phi = linspace(0,360,(n_fold+1));
phi = phi(1:end-1);

% Generate cell array with triplets
angles = cell(n_fold*2,1);
c = 1;
for i = 1:n_fold*2
    angles{c} = [phi(i),0,0];
    angles{c+1} = [phi(i),0,180];
    c = c+2;
end

end


%% Return tetrahedral angles
% function angles = get_tetrahedral_angles()
% angles = {[0, 0, 0];
%           [180,0,0]
%           [0,0,180];
%           [180,0,180];
%           [-45,45,90]};
% end


%           [0, 180, 0];
%           [0, 0, 90];
%           [180, 0, 90];
%           [0, 0, 180];
%           [0, 180, 180];
%           [180, 180, 90];
%           [0, 180, 90];
%           [-90, 90, 90];
%           [90, 90, 90];
%           [90, -90, 90];
%           [-90, -90, 90]};
% end


%% Return octahedral angles
function angles = get_octahedral_angles()
angles = {[0, 0, 0];
          [0, 90, 0];
          [0, 180, 0];
          [0, -90, 0];
          [0, 0, 90];
          [90, 0, 90];
          [180, 0, 90];
          [-90, 0, 90];
          [0, 0, 180];
          [0, 90, 180];
          [0, 180, 180];
          [0, -90, 180];
          [180, 180, 90];
          [-90, 180, 90];
          [0, 180, 90];
          [90, 180, 90];
          [-90, 90, 90];
          [0, 90, 90];
          [90, 90, 90];
          [180, 90, 90];
          [90, -90, 90];
          [180, -90, 90];
          [-90, -90, 90];
          [0, -90, 90]};
end


%% Return icosahedral angles
function angles = get_icosahedral_angles()
angles = {[0.0000000000, 0.0000000000, 0.0000000000];
          [-58.2822763651, 121.7177236349, 35.9997070184];
          [-20.9052722538, 159.0947277462, 60.0000000000];
          [20.9052722538, -159.0947277462, 60.0000000000];
          [58.2822763651, -121.7177236349, 35.9997070184];
          [0.0000000000, 180.0000000000, 0.0000000000];
          [58.2822763651, 58.2822763651, 35.9997070184];
          [-121.7177236349, 58.2822763651, 35.9997070184];
          [121.7177236349, 121.7177236349, 35.9997070184];
          [58.2826207834, 121.7173792166, 71.9998189280];
          [-121.7173792166, 121.7173792166, 71.9998189280];
          [159.0947277462, 159.0947277462, 60.0000000000];
          [-159.0947277462, -159.0947277462, 60.0000000000];
          [121.7173792166, -121.7173792166, 71.9998189280];
          [-58.2826207834, -121.7173792166, 71.9998189280];
          [-121.7177236349, -121.7177236349, 35.9997070184];
          [121.7177236349, -58.2822763651, 35.9997070184];
          [-58.2822763651, -58.2822763651, 35.9997070184];
          [58.2826207834, -58.2826207834, 71.9998189280];
          [-121.7173792166, -58.2826207834, 71.9998189280];
          [159.0947277462, -20.9052722538, 60.0000000000];
          [-20.9052722538, -20.9052722538, 60.0000000000];
          [20.9052722538, 20.9052722538, 60.0000000000];
          [-159.0947277462, 20.9052722538, 60.0000000000];
          [121.7173792166, 58.2826207834, 71.9998189280];
          [-58.2826207834, 58.2826207834, 71.9998189280];
          [0.0000000000, 90.0000000000, 90.0000000000];
          [90.0000000000, 180.0000000000, 90.0000000000];
          [-90.0000000000, 180.0000000000, 90.0000000000];
          [0.0000000000, -90.0000000000, 90.0000000000];
          [90.0000000000, 0.0000000000, 90.0000000000];
          [-90.0000000000, 0.0000000000, 90.0000000000];
          [159.0947277462, 20.9052722538, 120.0000000000];
          [20.9052722538, -20.9052722538, 120.0000000000];
          [-58.2826207834, -58.2826207834, 108.0001810720];
          [58.2822763651, -58.2822763651, 144.0002929816];
          [-159.0947277462, -20.9052722538, 120.0000000000];
          [121.7173792166, -58.2826207834, 108.0001810720];
          [58.2826207834, -121.7173792166, 108.0001810720];
          [180.0000000000, -90.0000000000, 90.0000000000];
          [20.9052722538, 159.0947277462, 120.0000000000];
          [159.0947277462, -159.0947277462, 120.0000000000];
          [121.7177236349, -121.7177236349, 144.0002929816];
          [-121.7173792166, -121.7173792166, 108.0001810720];
          [-20.9052722538, -159.0947277462, 120.0000000000];
          [-121.7177236349, 121.7177236349, 144.0002929816];
          [-58.2822763651, 58.2822763651, 144.0002929816];
          [0.0000000000, 0.0000000000, 180.0000000000];
          [-121.7177236349, -58.2822763651, 144.0002929816];
          [-58.2822763651, -121.7177236349, 144.0002929816];
          [0.0000000000, 180.0000000000, 180.0000000000];
          [-20.9052722538, 20.9052722538, 120.0000000000];
          [121.7177236349, 58.2822763651, 144.0002929816];
          [-121.7173792166, 58.2826207834, 108.0001810720];
          [180.0000000000, 90.0000000000, 90.0000000000];
          [58.2826207834, 58.2826207834, 108.0001810720];
          [58.2822763651, 121.7177236349, 144.0002929816];
          [-159.0947277462, 159.0947277462, 120.0000000000];
          [-58.2826207834, 121.7173792166, 108.0001810720];
          [121.7173792166, 121.7173792166, 108.0001810720]};
end


%% Combine Euler angles
function new_angles = combine_angles(angles,init_euler)

% Number of angles
n_angles = numel(angles);

% Initialize new angles
new_angles = cell(n_angles,1);

% Convert init_euler
q1 = sg_euler2quaternion(init_euler(1),init_euler(2),init_euler(3));

% Combine angles
for i = 1:n_angles
    q2 = sg_euler2quaternion(angles{i}(1),angles{i}(2),angles{i}(3));
    temp_q = sg_quaternion_multiply(q2,q1);
    [phi,psi,the] = sg_quaternion2euler(temp_q);
    new_angles{i} = [phi,psi,the];
end

end


%% Sum rotations
function sum_filt = sum_rotations(filt,angles)

% Get min and max values
nz_idx = filt ~= 0;
min_val = min(filt(nz_idx));
max_val = max(filt(nz_idx));

% Initialize new volume
dims = size(filt);
sum_filt = zeros(dims,'like',filt);

% Rotate and sum angles
n_ang = numel(angles);
for i = 1:n_ang
    
   % Rotate volume
   rfilt = sg_rotate_linear(filt,angles{i});
   rfilt = rfilt.*(rfilt <= max_val).*(rfilt >= min_val);
   
    % Sum rotated volumes 
    sum_filt = sum_filt + rfilt;
    



end


end











