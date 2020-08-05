function fom_avg = apply_fom_weighting(ref_A,ref_B,fsc)
%% apply_fom_weighting
% Take two halfset averages and a FSC curve and generate a figure-of-merit
% weighted average.
%
% WW 06-2019

%% Generate average

% Calculate figure-of-merit curve
Cref = real(sqrt((2.*abs(fsc))./(1+abs(fsc))));

% Calcualte distance array
r = sg_distancearray(ref_A,1);

% Interpolate 3D filter
filter = interp1(0:numel(fsc)-1,Cref,r,'pchip',0);

% Calculate average
fom_avg = (ref_A + ref_B)./2;
fom_avg = real(ifftn(fftn(fom_avg).*ifftshift(filter)));

