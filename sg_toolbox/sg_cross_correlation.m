function cc = sg_cross_correlation(vol1,vol2,mask)
%% sg_cross_correlation
% A function to return the cross-correlcation between two inputs. 
%
% WW 09-2020



%% Calculate autocorrelation

% Apply mask
if nargin == 3
    vol1 = vol1.*mask;
    vol2 = vol2.*mask;
end 

% Number of dimensions
n_dims = ndims(vol1);

% Calculate Fourier transform
switch n_dims    
    case 1
        ft1 = fft(vol1);
        ft2 = fft(vol1);
    case 2 
        ft1 = fft2(vol1);
        ft2 = fft2(vol2);
    otherwise
        ft1 = fftn(vol1);
        ft2 = fftn(vol2);
end

% Calculate correlation
corr = ft1.*conj(ft2);

% Inverse transform
switch n_dims    
    case 1
        cc = ifft(corr);
    case 2 
        cc = ifft2(corr);        
    otherwise
        cc = ifftn(corr);
end


% Shift cc
cc = real(ifftshift(cc));


% Normalize CC
csum2 = sum(vol2(:));
csum2_2 = sum(vol2(:).^2);
sigma1 = std(vol1(:))*sqrt(numel(vol1)-1);
sigma2 = sqrt(csum2_2-((csum2^2)./numel(vol2)));
cc = (cc-(mean(vol1(:))*csum2))./(sigma1*sigma2);





