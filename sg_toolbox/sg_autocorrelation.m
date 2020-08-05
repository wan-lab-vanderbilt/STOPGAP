function acf = sg_autocorrelation(vol,mask)
%% will_autocorrelation_function
% A function to return the autocorrelcation function of a given input. 
%
% The ACF is rescaled such that the central pixel equals 1.
%
% WW 02-2018



%% Calculate autocorrelation

% Apply mask
if nargin == 1
    vol = vol.*mask;
end 

% Number of dimensions
n_dims = ndims(vol);

% Calculate Fourier transform
switch n_dims    
    case 1
        ft = fft(vol);
    case 2 
        ft = fft2(vol);
    otherwise
        ft = fftn(vol);
end

% Calculate correlation
corr = ft.*conj(ft);

% Inverse transform
switch n_dims    
    case 1
        acf = real(ifft(corr));
    case 2 
        acf = real(ifft2(corr));        
    otherwise
        acf = real(ifftn(corr));
end

% Central pixel value
cen_val = acf(1);

% Shift and rescale acf
acf = ifftshift(acf)./cen_val;

