function v = generate_fourier_shells(o,v,shells)
%% generate_fourier_shells
% A function to calculate a cell array containing the indices  of Fourier 
% shells. This can be calculated with all shells or according to a set of
% indices. 
%
% This script expects a distance array stored as v.dist_array.
%
% WW 02-2018

%% Check check

if nargin == 2
    shells = 1:floor(o.boxsize/2);
end


%% Calcuate shell masks

% Number of shells 
v.n_shells = numel(shells);

% Precalculate shell masks
v.shell_mask = cell(v.n_shells,1);
for i = 1:v.n_shells
    % Shells are set to one pixel size
    shell_start = (shells(i)-1);
    shell_end = shells(i);
    
    % Generate shell mask
    temp_mask = (v.dist_array >= shell_start) & (v.dist_array < shell_end);
    
    % Write out linearized shell mask
    v.shell_mask{i} = temp_mask;
end


