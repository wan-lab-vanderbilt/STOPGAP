function motl = sg_motl_randomize_eulers_by_symmetry(motl,symmetry,output_name)
%% sg_motl_randomize_eulers_by_symmetry
% Take an input motivelist and apply a random symmetry operation to each
% entry. This can help remove preferred orientation problems caused by
% searching around only a symmetrical portion of angle space.
%
% WW 08-2023

%% Check check

% Read motl
if ischar(motl)
    motl = sg_motl_read2(motl);
end

% Check for C1
if strcmpi(symmetry,'c1')
    return
end



%% Initialize

% Determine number of entries
motl_idx = unique(motl.motl_idx);
n_motl = numel(motl_idx);


% Generate symmetry angles
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
n_angles = numel(angles);


% % Parse euler angles
% eulers = cat(2,motl.phi,motl.psi,motl.the);



%% Randomize angles

% Loop through entries
for i = 1:n_motl
    
    % Determine entry indices
    idx = find([motl.motl_idx] == motl_idx(i));
    
    for j = 1:numel(idx)
        
        % Convert old angle
        q1 = sg_euler2quaternion(motl.phi(idx(j)),motl.psi(idx(j)),motl.the(idx(j)));

        % Pick random euler
        r = randi(n_angles);
        q2 = sg_euler2quaternion(angles{r}(1),angles{r}(2),angles{r}(3));
        
        % Generate new angle
        temp_q = sg_quaternion_multiply(q1,q2);
        [phi,psi,the] = sg_quaternion2euler(temp_q);
        
        % Write output
        motl.phi(idx(j)) = phi;
        motl.psi(idx(j)) = psi;
        motl.the(idx(j)) = the;    
    end
end

%% Write output
if nargin == 3
    sg_motl_write2(output_name,motl);
end

