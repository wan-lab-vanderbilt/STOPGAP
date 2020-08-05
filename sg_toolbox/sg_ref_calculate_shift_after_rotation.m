%% sg_ref_calculate_shift_after_rotation
% Calculate shift between reference and template volumes.
%
% WW 09-2018


%% Inputs

% Volumes
ref_name = 'ref_14.mrc';
mask_name = '../../masks/mask.mrc';
rot_ref_name = 'rot_ref.mrc';
ali_ref_name = 'ali_ref.mrc';

% Angle
q = sg_axisangle2quaternion([1,0,0],1);
[phi,psi,the] = sg_quaternion2euler(q);

% Bandpass filter
lp_rad = 42;
lp_sigma = 3;
hp_rad = 8;
hp_sigma = 2;


%% Initialize

% Read volumes
ref = sg_volume_read(ref_name);
mask = sg_volume_read(mask_name);
boxsize = size(ref,1);
cen = floor(boxsize/2)+1;

% Generate bandpass filter
lowpass = sg_sphere(boxsize,lp_rad,lp_sigma);
hipass = sg_sphere(boxsize,hp_rad,hp_sigma);
bandpass = ifftshift(lowpass-hipass); % Bandpass filter

% Filter reference
fref = fftn(ref);
fref = fref.*bandpass;
fref(1,1,1) = 0;

% Store complex conjugate
conjRef = conj(fref); 
% Filtered particle
filt_ref = real(ifftn(fref));
% Store complex conjugate of square
conjRef2 = conj(fftn(filt_ref.^2));

%% Determine shift


% Rotate volume
r_ref = sg_rotate_vol(ref,[phi,psi,the]);
r_mask = sg_rotate_vol(mask,[phi,psi,the]);

% Filter rotated ref
fr_ref = real(ifftn(fftn(r_ref).*bandpass));

% Normalize under mask
mfr_ref = normalize_under_mask(fr_ref,r_mask); 

% Score
scoring_map = calculate_flcf(mfr_ref,r_mask,conjRef,conjRef2);

% Find ccc peak
[pos, score] = find_subpixel_peak(scoring_map.*sg_sphere(128,3));
shift = pos-cen;  % Shift from center of box
disp(['Shift: ',num2str(shift)]);

% Align motl
ali_ref = sg_shift_vol(r_ref,shift);

% Write outputs
sg_mrcwrite(rot_ref_name,r_ref);
sg_mrcwrite(ali_ref_name,ali_ref)



