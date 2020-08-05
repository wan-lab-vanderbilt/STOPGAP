function filt_vol = sg_bandpass_filter_tomogram(vol,varargin)
%% sg_bandpass_filter_tomogram
% Apply a bandpass filter to a tomogram. Inputs are taken as high and low 
% resolution cutoffs in Angstroms or fraction of absolute frequency, where 
% Nyquist = 1. High and low reoslution cutoffs require a given input size.
% 
% Filter edge smoothness can be set in Fourier voxels.
%
% Parameters are given as name value pairs:
% hp_res        =   high-pass resolution
% lp_res        =   low-pass resolution
% hp_freq       =   high-pass frequency
% lp_freq       =   low-pass frequency
% pixelsize     =   pixel size in Angstroms
% hp_sigma      =   high-pass filter dropoff
% lp_sigma      =   low-pass filter dropoff
%
% Because filtering is dependant on Fourier gridding and volume size, input
% resolution cutoffs cannot be precisely delivered. The approximate
% resolutions are written out if pixelsize is given.
%
% WW 01-2019

%% Parse paramters
disp('Parsing inputs...');

% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'hp_res',[]);
addParameter(parser,'lp_res',[]);
addParameter(parser,'hp_freq',[]);
addParameter(parser,'lp_freq',[]);
addParameter(parser,'pixelsize',[]);
addParameter(parser,'hp_sigma',2);
addParameter(parser,'lp_sigma',3);

% Parse arguments
parse(parser,varargin{:});
p = parser.Results;

% Check for double resolution inputs
if ~isempty(p.hp_res) && ~isempty(p.hp_freq)
    error('ACHTUNG!!! Two types of high-resolution input were given!!!');
end
if ~isempty(p.lp_res) && ~isempty(p.lp_freq)
    error('ACHTUNG!!! Two types of high-resolution input were given!!!');
end

% Check for pixelsize
if ~isempty(p.hp_res) || ~isempty(p.lp_res)
    if isempty(p.pixelsize)
        error('ACHTUNG!!! pixelsize is a required input when using resoultion cutoffs!!!');
    end
end


%% Parse volume dimensions

% Parse size of volume
dims = size(vol);

% Max dimension for 1D bpf
max_dim = max(dims);


%% Generate 1D bandpass filter
disp('Calculating 1D bandpass filter...');

% High-pass radius
if ~isempty(p.hp_res)
    hp_rad = floor((max_dim*p.pixelsize)/p.hp_res);
elseif ~isempty(p.hp_freq)
    hp_rad = floor(max_dim*p.hp_freq);
else
    hp_rad = 0;
end


% Low-pass radius
if ~isempty(p.lp_res)
    lp_rad = floor((max_dim*p.pixelsize)/p.lp_res);
elseif ~isempty(p.lp_freq)
    lp_rad = floor(max_dim*p.lp_freq);
else
    lp_rad = max_dim;
end

% 1D distance array
dist_1d = 0:(max_dim/2);


% Generate high-pass filter
if hp_rad > 0
    hp_idx = dist_1d <= hp_rad;
    hpf = zeros(size(dist_1d));
    hpf(hp_idx) = 1;
    hpf(~hp_idx) = exp(-((dist_1d(~hp_idx) - hp_rad)/p.hp_sigma).^2);
else
    hpf = zeros(size(dist_1d));
end
    
% Generate low-pass filter
if hp_rad < max_dim
    lp_idx = dist_1d <= lp_rad;
    lpf = zeros(size(dist_1d));
    lpf(lp_idx) = 1;
    lpf(~lp_idx) = exp(-((dist_1d(~lp_idx) - lp_rad)/p.lp_sigma).^2);
else
    lpf = ones(size(dist_1d));
end

% Generate bandpas filter
bpf = lpf - hpf;
bpf(bpf<exp(-4)) = 0;

% Display cutoffs
if ~isempty(p.pixelsize)
    disp(['Approximate high-pass cutoff: ',num2str((max_dim*p.pixelsize)/hp_rad,'%.2f'),' Angstroms']);
    disp(['Approximate low-pass cutoff: ',num2str((max_dim*p.pixelsize)/lp_rad,'%.2f'),' Angstroms']);
end


%% Calculate 3D filter
disp('Calculating 3D bandpass filter...');

% Generate frequency arrays
freq_1d = ((dist_1d./max_dim).*2);
freq_tomo = sg_frequencyarray(zeros(dims),0.5);

% Tomogram filter
tomo_bpf = ifftshift(interp1(freq_1d,bpf,freq_tomo,'linear',0));
clear freq_tomo


%% Calculate 3D transform
disp('Applying bandpass filter...');

% Transform input volume
ft_vol = fftn(vol);
clear vol

% Apply filter and inverse transform
filt_vol = real(ifftn(ft_vol.*tomo_bpf));











