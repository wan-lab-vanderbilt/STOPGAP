function varargout = calculate_3d_bandpass_filter(boxsize,lp_rad,lp_sigma,hp_rad,hp_sigma,varargin)
%% calculate_3d_bandpass_filter
% Generate a 3D bandpass fitler for an arbitrary boxsize. The array is
% first calculated as a 1D bandpass filter with respect to the largest box
% dimension, then interpolated to 3D. 
%
% If additional boxsizes are provided, additional bandpass filters are also
% generated using the Fourier scaling of the original. 
%
% WW 06-2019

%% Check boxsizes

% Check number of filters
n_filt = 1 + numel(varargin);

% Boxsize
boxsize_cell = cell(n_filt,1);

% Check dimension
if numel(boxsize) == 1       
    boxsize_cell{1} = ones(1,3).*boxsize; 
elseif numel(boxsize) == 3 
    boxsize_cell{1} = boxsize;
else
    error('Incorrect number of inputs for boxsize!!!');
end

% Check other boxsizae
for i = 1:numel(varargin)
    if numel(varargin{i}) == 1
        boxsize_cell{i+1} = ones(1,3).*varargin{i}; 
    elseif    numel(varargin{i}) == 3    
        boxsize_cell{i+1} = varargin{i};
    else
        error(['Incorrect number of inputs for filter ',num2str(i+1),'!!!']);
    end
end

% Initialize output
varargout = cell(n_filt,1);


%% Calculate 1D bpf

% Radius of 1D filter
radius = ceil(max(boxsize_cell{1})/2);

% Radius of bpf as fraction Nyquist
f_radius = (0:radius)./radius;    

% Calculate 1D bandpass filter
bpf_1d = sg_bandpass_filter_1d(radius,lp_rad,lp_sigma,hp_rad,hp_sigma);

%% Calculate 3D bandpass filters

for i = 1:n_filt
    
    % Frequency array for box
    temp_f = ifftshift(sg_frequencyarray(zeros(boxsize_cell{i},'single'),0.5));    % Radial array as fraction Nyquist
    
    % Generate filer
    varargout{i} = interp1(f_radius,bpf_1d,temp_f,'pchip',0);    % Generate template bpf by interpolation
    varargout{i} = varargout{i}.*(varargout{i}>exp(-2));
end


