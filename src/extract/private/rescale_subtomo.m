function rsubtomo = rescale_subtomo(subtomo,boxsize,f)
%% rescale_subtomo
% Rescale subtomo in Fourier space using pre-computed indices.
%
% WW 02-2018

%% Rescale

% Transform subtomo
ft_subtomo = fftn(subtomo);

% Initialize new subtomo
ft_rsubtomo = zeros(boxsize,boxsize,boxsize);

% Write information
ft_rsubtomo(f.box_idx) = ft_subtomo(f.ex_idx);

% Inverse transform
rsubtomo = real(ifftn(ft_rsubtomo.*f.lpf));

