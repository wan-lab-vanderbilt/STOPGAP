%% sg_align_volumes
% A function to align one or a set of template volumes to a reference
% volume. Input volume is either given as a volume file or as a .txt file
% containing a list of input volumes. The output is written as a stopgap
% motivelist in the same order as the input list. 
%
% No missing wedge is taken into account during alignment. 
%
% WW 05-2019

%% Inputs

% Reference volume
ref_name = 'ref_A_16.mrc';
ref_sym = 'C1';

% Template name
tmpl_name = 'ref_A_16.mrc';

% Mask name
mask_name = 'mask.mrc';

% CC maks name
ccmask_name = 'sphere.mrc';

% Angular search
angincr = 0.5;
angiter = 5;
phi_angincr = 0.5;
phi_angiter = 5;

% Bandpass filter
lp_rad = 42;
lp_sigma = 3;
hp_rad = 10;
hp_sigma = 2;

% Output name
output_name = 'align.star';


%% Initialize
disp('Initializing!!!');

% Read volumes
[v,o] = sg_ali_prepare_volumes(ref_name,ref_sym,tmpl_name,mask_name,ccmask_name,lp_rad,lp_sigma,hp_rad,hp_sigma);

% Aligned volumes
ali = cell(v.n_tmpl,1);

% Get search angles
o = sg_ali_cone_angles(o,angincr,angiter,phi_angincr,phi_angiter);


% Intiailize motivelist
motl = sg_initialize_motl(v.n_tmpl);
motl = sg_motl_fill_field(motl,'tomo_num',0);
motl = sg_motl_fill_field(motl,'object',0);
motl = sg_motl_fill_field(motl,'subtomo_num',1:v.n_tmpl);
motl = sg_motl_fill_field(motl,'halfset','A');
motl = sg_motl_fill_field(motl,'orig_x',0);
motl = sg_motl_fill_field(motl,'orig_y',0);
motl = sg_motl_fill_field(motl,'orig_z',0);
motl = sg_motl_fill_field(motl,'score',-2);
motl = sg_motl_fill_field(motl,'class',0);


%% Align templates
disp('Aligning volumes...');

for i = 1:v.n_tmpl
    disp(['Aligning ',v.tmpl_list{i}]);
    
    for j = 1:o.n_ang
        
      
        % Rotate template
        rotTemp = sg_rotate_vol(v.tmpl{i},o.anglist(:,j)');
        rotTemp = real(ifftn(fftn(rotTemp).*o.bandpass));
        
        % Rotate mask
        rotMask = sg_rotate_vol(o.mask,o.anglist(:,j)');
        rotMask(rotMask<exp(-2)) = 0;
        
        % Normalize under mask
        mTemp = normalize_under_mask(rotTemp,rotMask); 
        
        % Score
        scoring_map = calculate_flcf(mTemp,rotMask,v.conjRef,v.conjRef2);


        % Rotate CC mask
        rccmask = sg_rotate_vol(o.ccmask,o.anglist(:,j)');

        % Find ccc peak
        [pos, score] = find_subpixel_peak(scoring_map, rccmask);
        shift = pos-v.cen;  % Shift from center of box
        
        % Store parameters
        if score > motl(i).score
            ali{i} = sg_shift_vol(sg_rotate_vol(v.tmpl{i},o.anglist(:,j)'),shift);
            motl(i).score = score;
            motl(i).x_shift = shift(1);
            motl(i).y_shift = shift(2);
            motl(i).z_shift = shift(3);
            motl(i).phi = o.anglist(1,j);
            motl(i).psi = o.anglist(2,j);
            motl(i).the = o.anglist(3,j);
        end
        
    end
    
    % aligned name
    [path,name,ext] = fileparts(v.tmpl_list{i});
    if ~isempty(path)
        path = [path,'/'];
    end
    ali_name = [path,name,'_ali',ext];
    sg_mrcwrite(ali_name,ali{i});
    
    disp(['Aligning ',num2str(i),' out of ',num2str(v.n_tmpl),' templates aligned...']);
    
end

sg_motl_write(output_name,motl);







