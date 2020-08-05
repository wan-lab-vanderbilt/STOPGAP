function xf = sg_read_IMOD_xf(xf_name)
%% sg_read_IMOD_xf
% Read an IMOD .xf file and return as a struct array.
%
% WW 06-2019

%% Read xf

% Read xf
xf_data = dlmread(xf_name);
n_tilts = size(xf_data,1);

% Initialize struct
xf(n_tilts).rmat = zeros(2,2,'single');
xf(n_tilts).shift = zeros(2,1,'single');
xf(n_tilts).rot = zeros(1,1,'single');

% Fill struct
for i = 1:n_tilts
    
    % Parse rotation matrix
    xf(i).rmat = [xf_data(i,1),xf_data(i,2);xf_data(i,3),xf_data(i,4)];
    
    % Parse shift
    xf(i).shift = [xf_data(i,5);xf_data(i,6)];
    
    % Calculate rotation angle
    xf(i).rot = acosd(xf(i).rmat(1,1));
    
end



