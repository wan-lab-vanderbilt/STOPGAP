function sharp_ref = sg_sharpen_reference(ref,b_factor,pixelsize)
%% sg_sharpen_reference
% A function to apply an exponential sharpening filter to a reference. For
% more information, see: Rosenthal and Henderson 
% (doi: 10.1016/j.jmb.2003.07.013). 
%
% For proper filtering, reference should also be figure-of-merit weighted
% and low-pass filtered to your desired FSC threshold.
%
% WW 06-2018

%% Sharpen!!!

% Calculate frequency array
boxsize = size(ref,1);
r_size = ceil(boxsize/2);
R = 1:r_size;
R = (boxsize*pixelsize)./R;

% Calculate exponential filter
rad_filt = exp(-(b_factor./(4.*(R.^2))));
exp_filt = tom_sph2cart(repmat(rad_filt',[1, (4*r_size), (2*r_size)]));


% Filter reference   
ft_ref = fftn(ref);
sharp_ref = ifftn(ft_ref.*ifftshift(exp_filt));


