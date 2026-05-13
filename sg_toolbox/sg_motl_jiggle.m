function sg_motl_jiggle(input_name,output_name,max_shift,apply_shifts)
%% sg_motl_jiggle
% Apply a random shift up to the max_shift variable. The apply_shifts
% variable will apply the shifts to the original coordinates. The random
% shifts have an even distribution.
%
% This function can be useful if the input_motl is sampled on a grid and
% needs to be blurred out. 
%
% max_shift can be 1 number for all dimensions, or 3 numbers defining
% max_shift in each direction. 
%
% WW 01-2026

% % %DEBUG
% input_name = 'trunk_1.star';
% output_name = 'trunk_jiggle2_1.star';
% max_shift = [2,4,2];
% apply_shifts = false;
   
%% Check check

% Check shifts
if numel(max_shift) == 1
    max_shift = max_shift.*ones(1,3);
elseif numel(max_shift) == 3
    max_shift = reshape(max_shift,1,3); % Force dimensionality
elseif numel(max_shift) ~= 3
    error('ACHTUNG!!! max_shift must either be 1 or 3 numbers!!!')
end

    
%% Jiggle

% Read motl
motl = sg_motl_read2(input_name);
n_motls = numel(motl.motl_idx);

% Calculate jiggle
jiggle = rand(n_motls,3).*repmat(max_shift,n_motls,1);

% Calculate rotated shifts
for i = 1:n_motls
    
    % Calculate quaterion
    q = sg_euler2quaternion(motl.phi(i),motl.psi(i),motl.the(i));
    
    % Rotate shift
    shift = sg_quaternion_rotate(q,jiggle(i,:));
        
    % Add shifts
    motl.x_shift(i) = motl.x_shift(i) + shift(1);
    motl.y_shift(i) = motl.y_shift(i) + shift(2);
    motl.z_shift(i) = motl.z_shift(i) + shift(3);
    
end

%% Output motl

% Write output
if apply_shifts
    sg_motl_apply_shifts(motl,output_name);
else
    sg_motl_write2(output_name,motl);
end


