function acf = sg_autocorrelation2(vol,mask)
%% will_autocorrelation_function
% A function to return the autocorrelcation function of a given input. 
%
% The ACF is rescaled such that the central pixel equals 1.
%
% WW 02-2018



%% Calculate autocorrelation

% Apply mask
if nargin == 2
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


% Shift acf
acf = ifftshift(acf);

% Normalize acf
csum2 = sum(vol(:));
csum2_2 = sum(vol(:).^2);
sigma1 = std(vol(:))*sqrt(numel(vol)-1);
sigma2 = sqrt(csum2_2-((csum2^2)./numel(vol)));
acf = (acf-(mean(vol(:))*csum2))./(sigma1*sigma2);

