function sym_vol = sg_symmetrize_volume(vol,symmetry,init_euler,center,reweight,binary)
%% sg_symmetrize_volume
% Apply point group symmetry operator to a volume. Operators follow
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
% "init_euler" and 'center' inputs.
%
% If reweight is enabled, the average is reweigheted by the sampled
% regions. Otherwise, the average is calculated as a basic division by the
% number of angles.
%
% If 'binary' is true, input volumes are thresholded at 0.5 after each
% rotation.
%
% WW 12-2018

%% Check check

% Check for C1
if strcmpi(symmetry,'c1')
    sym_vol = vol;
    return
end

% Check threshold
if nargin < 6
    binary = false;
end

% Check normalization
if nargin < 5
    reweight = true;
end

% Check center
if nargin < 4
    center = [];
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
        angles = sg_get_cyclic_angles(c_sym);
    case 'd'
        c_sym = str2double(symmetry(2:end));
        angles = sg_get_dihedral_angles(c_sym);
%     case 't'
%         angles = get_tetrahedral_angles();
    case 'o'
        angles = sg_get_octahedral_angles();
    case 'i'
        angles = sg_get_icosahedral_angles();
    otherwise
        error('ACHTUNG!!! Invalid symmetry operator!!!');
end

% Apply initial orientation
if ~isempty(init_euler)
    angles = combine_angles(angles,init_euler);
end

%% Apply symmetry

% Sum symmetric volumes
sym_vol = sum_rotations(vol,angles,center,binary);

if reweight
    
    % Weighitng array
    sym_wei = sum_rotations(ones(size(vol),'like',vol),angles,center);

    % Return symmetrized volumed
    sym_vol = sym_vol./sym_wei;
    
else
    
    % Divide by number of angles
    sym_vol = sym_vol./numel(angles);

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
function sum_vol = sum_rotations(vol,angles,center,binary)

% Check for threshold
if nargin < 4
    binary = 0;
end

% Initialize new volume
dims = size(vol);
sum_vol = zeros(dims,'like',vol);

% Rotate and sum angles
n_ang = numel(angles);
for i = 1:n_ang
    
   
    % Sum rotated volumes 
    if binary
        sum_vol = sum_vol + (sg_rotate_linear(vol,angles{i},center) >= 0.9);        
    else
        sum_vol = sum_vol + sg_rotate_linear(vol,angles{i},center);
    end
    
       
    


end


end











