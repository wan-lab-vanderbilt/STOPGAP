function o = calculate_arbitrary_eulers(p,o,idx)
%% calculate_arbitrary_eulers
% A function for generating search angles for arbitrary euler triplets.
% Angular searches are on evenly-spaced grids, and compute all possible
% permutations of angles. 
%
% This can generate a very large number of angles unless they are well 
% restricted. For general searches, cone-search is probably more efficient.
%
% WW 01-2018


% input_axes = 'z,x,y';
% input_angles = '10,3,10,3,10,1';

%% Initialize axial vectors
a = struct;
a.x = [1,0,0];
a.y = [0,1,0];
a.z = [0,0,1];

%% Parse inputs

% Parse axes
if numel(p(idx).euler_axes) == 3
    % Axes without delimitation
    axes = cell(1,3);
    for i = 1:3
        axes{i} = p(idx).euler_axes(i);
    end
elseif numel(p(idx).euler_axes) < 3
    error('ACHTUNG!!! Invalid euler_axes!!!');    
else
    % Split delimited axes
    axes = strsplit(lower(p(idx).euler_axes),{',',' '},'CollapseDelimiters',1);
    n_axes = numel(axes);
    if ~all(strcmp(axes,{'x'}) + strcmp(axes,{'y'}) + strcmp(axes,{'z'}));
        error('ACHTUNG!!! Only "x","y",or "z" are supported as axes. Deliniate with comas or spaces!');
    end

    if n_axes ~= 3
        error('ACHTUNG!!! Three euler angles are required!!!');
    end
end

% Parse angles
angles  = zeros(2,3);
angles(1,1) = p(idx).euler_1_incr;
angles(2,1) = p(idx).euler_1_iter;
angles(1,2) = p(idx).euler_2_incr;
angles(2,2) = p(idx).euler_2_iter;
angles(1,3) = p(idx).euler_3_incr;
angles(2,3) = p(idx).euler_3_iter;

%% Generate angle combinations

% Generate Euler angles
angle_array = cell(3,1);
for i = 1:3
    angle_array{i} = -(angles(1,i)*angles(2,i)):angles(1,i):(angles(1,i)*angles(2,i));  % Angular range for each axis
    if isempty(angle_array{i})
        angle_array{i} = 0;
    end
end

% All euler combinations
ang_perm = combvec(angle_array{1},angle_array{2},angle_array{3});
o.n_ang = size(ang_perm,2);

% Sort to place zero-rotation in position 1
idx = find(sum(abs(ang_perm),1)==0);
ang_perm = circshift(ang_perm,[1,-idx+1]);

%% Generate euler triples

% Initialize new eulers
o.q_ang = cell(o.n_ang,1);

% Generate new angles

for i = 1:o.n_ang

    % Convert single rotations to quaternions
    q1 = axisangle2quaternion(a.(axes{1}),ang_perm(1,i));
    q2 = axisangle2quaternion(a.(axes{2}),ang_perm(2,i));
    q3 = axisangle2quaternion(a.(axes{3}),ang_perm(3,i));
    
    % Combine rotations
    q = quaternion_multiply(q3,q2,q1);
    
    % Store quaternion
    o.q_ang{i} = q;    
    
end



