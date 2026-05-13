function sg_tm_batch_boundary_mask(tomo_ext,mask_suffix,padding)
%% sg_tm_batch_boundary_mask
% A batch function for generating boundary masks. This function scans the
% current directory for all files ending with the tomo_ext file extension.
% For TOMOMAN tomograms, this is typically '.rec'. 
%
% After compiling a list of volume names [tomo_name][tomo_ext], it looks
% for IMOD model files with name [tomo_name]_[mask_suffix].mod. It converts
% these to text files and writes out a boundary mask as
% [tomo_name]_[mask_suffix].mrc.
%
% padding is the number of pixels around the edge of the tomogram to clear
% from the mask. This should be half your template size to avoid issues
% with particles off the edge of the tomogram. 
%
% WW 01-2026

%%%% DEBUG
% tomo_ext = '.rec';
% mask_suffix = 'boundary';
% padding = 16;

%% Initialize

% Get volumes
d = dir(['*',tomo_ext]);
n_tomos = numel(d);


%% Generate masks

for i = 1:n_tomos
    
    % Parse filename
    [~,tomo_name,~] = fileparts(d(i).name);
    
    % Check for model file
    mod_name = [tomo_name,'_',mask_suffix,'.mod'];
    if ~exist(mod_name,'file')
        warning(['ACHTUNG!!! .mod file for ',tomo_name,' not found!!!']);
        continue
    end
    
    % Convert to text file
    txt_name = [tomo_name,'_',mask_suffix,'.txt'];
    system(['model2point -input ',mod_name,' -output ',txt_name]);
    
    % Create boundary mask
    mask_name = [tomo_name,'_',mask_suffix,'.mrc'];
    sg_mrcwrite(mask_name,sg_tm_create_boundary_mask(d(i).name,txt_name,padding));
    
    disp(['Boundary mask created for: ',tomo_name]);
    
end
    



