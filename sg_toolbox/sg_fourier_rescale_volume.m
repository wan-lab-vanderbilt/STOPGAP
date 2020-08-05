function svol = sg_fourier_rescale_volume(vol,scale)
%% sg_fourier_rescale_volume
% Rescale a volume in Fourier space.
%
% WW 08-2018

%% Check check
    
if scale == 1    
    svol = vol;
    return
end

%% Rescale

% Get dimensions
dims = size(vol);

% New dimensions
n_dims = floor(dims.*scale);

% Fourier transform
ft_vol = fftshift(fftn(vol));

if scale > 1
    
    % Initialize larger volume
    ft_svol = zeros(n_dims,'like',ft_vol);
    
    % Indices
    r1 = floor((n_dims - dims)./2) + 1;
    r2 = r1 + dims - 1;
    
    % Place old Fourier transform
    ft_svol(r1(1):r2(1),r1(2):r2(2),r1(3):r2(3)) = ft_vol;
    
    
elseif scale < 1
    
    % Indices
    r1 = floor((dims - n_dims)./2) + 1;
    r2 = r1 + n_dims - 1;
    
    % Fourier crop
    ft_svol = ft_vol(r1(1):r2(1),r1(2):r2(2),r1(3):r2(3));
    
end

svol = real(ifftn(ifftshift(ft_svol)));


