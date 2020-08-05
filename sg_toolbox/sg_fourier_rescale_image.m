function r_img = sg_fourier_rescale_image(image,scale,pad_img)
%% sg_fourier_rescale_image
% A function for rescaling images in Fourier space. There will generally be
% an small scaling error owing to the Fourier pixel increments, though this
% is usually under 1%.
%
% For shrinking images,the rescaled imaged is padded to the same dimensions
% as the original image by default. This can be set using the 'pad_img'
% parameter.
%
% WW 12-2019

%% Check check
if scale == 1
    r_img = image;
    return
end

if nargin == 2
    pad_img = true;
end

%% Initialize

% Determine size of FT
dims = size(image);
new_dims = round_to_even(dims.*scale);
real_scale = new_dims(1)/dims(1);       % Required for proper grey-value reweighting

% Transform image
ft_img = fftshift(fft2(image));

%% Rescale image in Fourier space

if real_scale > 1
    
    % Padding/cropping indices
    x1 = ((new_dims(1)-dims(1))/2)+1;
    x2 = x1 + dims(1) -1;
    y1 = ((new_dims(2)-dims(2))/2)+1;
    y2 = y1 + dims(2) -1;
        
    % Pad in Fourier space
    pad_ft_img = zeros(new_dims);
    pad_ft_img(x1:x2,y1:y2) = ft_img;
    
    % Stretched image
    new_img = ifft2(ifftshift(pad_ft_img));
    
    % Crop to input size
    r_img = real(new_img(x1:x2,y1:y2))*(real_scale^2);  % Also rescale grey values
    
else
    
    % Padding/cropping indices
    x1 = ((dims(1)-new_dims(1))/2)+1;
    x2 = x1 + new_dims(1) -1;
    y1 = ((dims(2)-new_dims(2))/2)+1;
    y2 = y1 + new_dims(2) -1;
    
    % Shrunken image
    new_img = real(ifft2(ifftshift(ft_img(x1:x2,y1:y2))))*(real_scale^2);  % Also rescale grey values    

    % Pad image to input size
    if pad_img
        r_img = zeros(dims);
        r_img(x1:x2,y1:y2) = new_img;
    else
        r_img = new_img;
    end
    
    
end


% Check output type
switch class(image)
    case 'int32'
        r_img = int32(r_img);
    case 'single'
        r_img = single(r_img);
end


end

%% round_to_even
% Round to nearest even integer.

function rnum = round_to_even(num)
    rnum = floor(num);
    if mod(rnum,2)
        rnum = rnum+1;
    end
end
