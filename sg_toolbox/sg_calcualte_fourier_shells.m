function [shell_mask,n_shells] = sg_calcualte_fourier_shells(boxsize,fftshifted)
%% sg_calcualte_fourier_shells
% Calculate mask indices for Fourier shells. Fourier shells start at R = 0.
%
% WW 06-2019

%% Check check
if nargin == 1
    fftshifted = false;
end

%% Calculate shells

% Distance array
R = sg_distancearray(zeros(boxsize,boxsize,boxsize),1);
if fftshifted
   R =  ifftshift(R);
end

% Number of Fourier Shells
n_shells = boxsize/2;  % Hardcoded to half the box-size

% Precalculate shell masks
shell_mask = cell(n_shells,1);
for i = 1:n_shells
    % Shells are set to one pixel size
    shell_start = (i-1);
    shell_end = i;
    
    % Generate shell mask
    temp_mask = (R >= shell_start) & (R < shell_end);
    
    % Write out linearized shell mask
    shell_mask{i} = temp_mask(:);
end

