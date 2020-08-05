function shift_vol = sg_shift_vol(vol, shift, fs_grid)
%% sg_shift_vol
% Apply a real-space shift to a 3D volume via a Fourier space phase shift.
%
% If the input is given as a complex array, it is assumed that the
% input volume is in Fourier space and a phase-shifted Fourier volume is
% returned. Fourier volumes should be supplied without fftshift, i.e. voxel
% 1 should be the zero-frequency.
%
% For computational efficeincy, a Fourier space grid can be pre-calculated 
% for a given volume size. For a real-space volume, the grid should NOT be 
% fftshifted; i.e. voxel 1 should be the zero frequency. For a Fourier
% volume input, the fftshifting of the grid should match the volume.
%
% WW 10-2018

%% Check check

% Volume dimensions
dims = zeros(3,1);
[dims(1),dims(2),dims(3)] = size(vol);
n_dims = sum(dims~=1);

% Check shift
switch numel(shift)
    case 2
        shift = [shift(:);1];
    case 1
        shift = [shift;1;1];       
end

% Check grid
if (nargin < 3) || isempty(fs_grid)
    fs_grid = sg_fourier_shift_grid(dims(1),dims(2),dims(3),false);
elseif ~isempty(fs_grid)
    [gx,gy,gz] = size(fs_grid.x);
    if (gx~=dims(1)) || (gy~=dims(2)) || (gz~=dims(3))
        error('ACTHUNG!!! Size of fs_grid and vol do not match!!!');
    end
end

% Check for Fourier volume
if isreal(vol)    
    switch n_dims
        case 1
            ft_vol = fft(vol);
        case 2
            ft_vol = fft2(vol);
        case 3
            ft_vol = fftn(vol);
    end
else
    ft_vol = vol;
end
        

%% Apply shift


% Calcualte shift vectors
shift_vec = shift(:)./dims(:);

% Signal delay for shift
tau = (shift_vec(1)*fs_grid.x) + (shift_vec(2)*fs_grid.y) + (shift_vec(3)*fs_grid.z);

% Calculate phase shift
phase_shift = exp(-2*pi*1i*tau);

% Apply phase shift
shift_ft_vol = ft_vol.*phase_shift;


% Check for Fourier volume
if isreal(vol)    
    switch n_dims
        case 1
            shift_vol = real(ifft(shift_ft_vol));
        case 2
            shift_vol = real(ifft2(shift_ft_vol));
        case 3
            shift_vol = real(ifftn(shift_ft_vol));
    end
else
    shift_vol = shift_ft_vol;
end

end


