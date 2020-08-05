function ali_vol = sg_align_volume(ref,target,mask,angincr,angiter,phi_angincr,phi_angiter,max_shift,lp_rad,lp_sigma,hp_rad,hp_sigma)
%% sg_align_volume
% Align a target volume to a reference volume using given input volume.
% Required are the two volumes, a mask, an angular search range, and the 
% maximum shift. Since  this is not meant for iterative alignment, the 
% search uses a fine cone  search.
%
% The final four paramters are used to define a bandpass filter. If no
% inputs are given, no filtering is performed. 
%
% WW 06-2020


%% Check check

% Check bandpass input
if (nargin < 12) && (nargin > 8)
    error('ACHTUNG!!! Invalid number of input arguments!!! Either all or no bandpass paramters must be given!!!');
end
if nargin <= 8
    filter = false;
else
    filter = true;
end

% Check number of arguments
if nargin < 8
    error('ACHTUNG!!! Invalid number of input arguments!!!');
end

% Check boxsizes
if ~all(size(ref)==size(target))
    error('ACHTUNG!!! Size of ref and target do not match!!!');
end



%% Initialize

% Initialize angle list








