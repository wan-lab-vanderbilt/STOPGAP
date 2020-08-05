function [ex_idx,box_idx] = calculate_fourier_indices(extract_size,boxsize)
%% calculate_fourier_indices
% Calculate the indices for Fourier rescaling between extracted volumes and
% final box.
%
% WW 12-2018

%% Calculate indices

% Scale
scale = boxsize/extract_size;

% Set sizes based on scale
if scale > 1    
    
    full_size = extract_size;
    crop_size = boxsize;
        
elseif scale < 1    
    
    full_size = boxsize;
    crop_size = extract_size;    
    
end


% Calcualte full indices
full_idx = true(full_size^3,1);

% Indices for Fourier cropping
crop_idx = false(crop_size,crop_size,crop_size);
crop_idx(1:full_size,1:full_size,1:full_size) = true;
halfbox = floor(full_size/2);
crop_idx = circshift(crop_idx,[-halfbox,-halfbox,-halfbox]);
crop_idx = crop_idx(:);


% Return indices based on scale
if scale > 1    
    
    ex_idx = full_idx;
    box_idx = crop_idx;
        
elseif scale < 1    
    
    ex_idx = crop_idx;
    box_idx = full_idx;    
    
end

