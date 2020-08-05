function rvol = sg_rotate_linear(vol,eulers,center)
%% sg_rotate_linear
% Stopgap wrapper for tom_rotate. This fixes some behaviors, such as
% placing the center pixel as floor(boxsize/2)+1. 
%
% It also ensures that the input type is the same as the output type.
%
% WW 09-2018


%% Check check

% Size of volume
dims = size(vol);

% Check center
if (nargin == 2) || isempty(center)
    center = floor(dims./2)+1;
elseif nargin ~= 3
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end
center = center - 1; % Ensure proper centering...

% Check number of eulers
if numel(eulers)~=3
    error('ACHTUNG!!! Incorrect number of input eulers!!!');
end


%% Perform rotation

% Check if input is double
d = isa(vol,'double');

% Convert to single
if d
    vol = single(vol);
end

% Preallocate memory
rvol = zeros(dims,'single'); 

% Call C-Function to do the calculations
tom_rotatec(vol,rvol,single(eulers),'linear',single(center));

% Convert back to doubles
if d
    rvol = double(rvol);
end


