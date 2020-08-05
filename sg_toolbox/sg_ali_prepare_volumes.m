function [v,o] = sg_ali_prepare_volumes(ref_name,ref_sym,tmpl_name,mask_name,ccmask_name,lp_rad,lp_sigma,hp_rad,hp_sigma)

%% Read reference
v.ref = sg_volume_read(ref_name);
v.boxsize = size(v.ref,1);
v.cen = floor(v.boxsize/2)+1;
v.ref = sg_symmetrize_volume(v.ref,ref_sym);


% Check check
if ~all(size(v.ref)==v.boxsize)
    error('ACHTUNG!!! Only cubic volumes supported!!!');
end

%% Bandpass filter

% Generate bandpass filter
lowpass = sg_sphere(v.boxsize,lp_rad,lp_sigma);
hipass = sg_sphere(v.boxsize,hp_rad,hp_sigma);
o.bandpass = ifftshift(lowpass-hipass); % Bandpass filter

%% Initialize reference

v.fref = fftn(v.ref);
v.fref = v.fref.*o.bandpass;
v.fref(1,1,1) = 0;

% Store complex conjugate
v.conjRef = conj(v.fref); 
% Filtered particle
filt_ref = real(ifftn(v.fref));
% Store complex conjugate of square
v.conjRef2 = conj(fftn(filt_ref.^2));


%% Read masks

% Read masks
o.mask = sg_volume_read(mask_name);
o.ccmask = sg_volume_read(ccmask_name);

%% Read templates

% Read templates
if strcmp(tmpl_name(end-3:end),'.txt')
    
    % Read template list
    fid = fopen(tmpl_name);
    tmpl_list = textscan(fid,'%s');
    fclose(fid);
    v.tmpl_list = tmpl_list{1};
    
    % Read templates
    v.n_tmpl = numel(tmpl_list{1});
    v.tmpl = cell(v.n_tmpl,1);
    for i = 1:v.n_tmpl
        v.tmpl{i} = sg_volume_read(v.tmpl_list{i});
        % Check check
        if ~all(size(v.tmpl{i})==v.boxsize)
            error(['ACHTUNG!!! Problem with: "',tmpl_list{1}{i},'" Only cubic volumes supported!!!']);
        end
    end
    
else
    
    % Read template
    v.n_tmpl = 1;
    v.tmpl = cell(1,1);
    v.tmpl{1} = sg_volume_read(tmpl_name);
    
    v.tmpl_list = cell(1,1);
    v.tmpl_list{1} = tmpl_name;
    % Check check
    if ~all(size(v.tmpl{1})==v.boxsize)
        error(['ACHTUNG!!! Problem with: "',tmpl_name,'" Only cubic volumes supported!!!']);
    end
    
end

