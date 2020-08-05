function v = prepare_tiles_tm(p,idx,o,f,v)
%% prepare_tiles_tm
% Prepare tiles for template matching.
%
% WW 04-2019

%% Prepare tiles


% Calculate Laplacian of template
if sg_check_param(p(idx),'apply_laplacian');
    v.tile = del2(v.tile);
end

% Fourier transform tile        
v.ft_tile = fftn(v.tile);
% Check Fourier cropping
if o.fcrop
    v.ft_tile = crop_fftshifted_vol(v.ft_tile,o.f_idx_tile);
end
% Apply filter
v.ft_tile = v.ft_tile.*f.tile_filt;
% Set 0-frequency peak to zero
v.ft_tile(1,1,1) = 0;



% Store complex conjugate
v.conjTile = conj(v.ft_tile); 
% Filtered particle
filt_tile = real(ifftn(v.ft_tile));
% Store complex conjugate of square
v.conjTile2 = conj(fftn(filt_tile.^2));



