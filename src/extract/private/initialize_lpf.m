function lpf = initialize_lpf(extract_size,boxsize)
%% initialize_lpf
% Calculate a lowpass filter for Fourier rescaling. This helps against edge 
% artifacts of if rescaled Fourier space doesn't fill the box. If scaling 
% factor is less than one, the lowpass filter fills all space.
%
% WW 12-2018


%% Calcuate lpf

% Scale
scale = boxsize/extract_size;

% Set sizes based on scale
if scale > 1    
    
    rad = floor(extract_size/2)-4;
    lpf = ifftshift(sg_sphere(boxsize,rad,2));
        
elseif scale < 1    
    
    lpf = ones(boxsize,boxsize,boxsize);
    
end



