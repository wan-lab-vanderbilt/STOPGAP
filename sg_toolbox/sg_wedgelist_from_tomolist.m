%% sg_wedgelist_from_tomolist
% A function to generate a stopgap wedgelist from a TOMOMAN tomolist.
%
% WW 07-2018

%% Inputs

% Tomogram files/folders
tomo_rootdir = '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/insitu_ribo_tm/tomo/';
tomolist_name = 'tomolist_103.mat';
imod_stack = 'df';  % Stack used for IMOD alignment. "df" for dose-filtered, 'uf' for unfiltered.
prefix = '';
digits = 1;

% Output name
subtomo_dir = './';
wedgelist_name = 'wedgelist.star';

% CTF parameters
voltage = 300;          % Voltage (keV)
amp_contrast = 0.07;    % Amplitude contrast
cs = 2.7;               % Spherical abberation (mm)


%% Initialize

% Read tomolist
load([tomo_rootdir,'/',tomolist_name]);
n_tomos = numel(tomolist);

% Initialize new wedgelist
w_fields = sg_get_wedgelist_fields;
% w_fields(8:11,:) = [];      % Unsupported fields
w_cell = cell(n_tomos,1);

% Check for defocus
if all(~[tomolist.ctf_determined])
    def = false;
%     w_fields(7,:) = [];
else
    def = true;
end




%% Fill wedgelist

for i = 1:n_tomos
    
    % Check for skip
    if tomolist(i).skip
        continue
    end
    
    % Initialize temporary wedgelist
    wedgelist_temp = struct();
    
    % Parse .tlt name
    switch imod_stack
        case 'uf'
            [path,name,~] = fileparts(tomolist(i).stack_name);
        case 'df'
            [path,name,~] = fileparts(tomolist(i).dose_filtered_stack_name);
    end
    if ~isempty(path)
        path = [path,'/']; %#ok<AGROW>
    end
    tlt_name = [path,name,'.tlt'];
    
    % Get wedge angles
    tilts = num2cell(dlmread([tomolist(i).stack_dir,tlt_name]));
    n_tilts = numel(tilts);
    [wedgelist_temp(1:n_tilts).tilt_angle] = tilts{:};
    
    % Parse parameters from tilt.com
    tiltcom  = sg_IMOD_parse_tiltcom([tomolist(i).stack_dir,'tilt.com']);

    % Assign parameters
    for j = 1:n_tilts
        wedgelist_temp(j).tomo_num = tomolist(i).tomo_num;
        wedgelist_temp(j).pixelsize = tomolist(i).pixelsize;
        wedgelist_temp(j).voltage = voltage;
        wedgelist_temp(j).amp_contrast = amp_contrast;
        wedgelist_temp(j).cs = cs;
        wedgelist_temp(j).tomo_x = tiltcom.FULLIMAGE(1);
        wedgelist_temp(j).tomo_y = tiltcom.FULLIMAGE(2);
        wedgelist_temp(j).tomo_z = tiltcom.THICKNESS;
        if isempty(tiltcom.SHIFT)
            wedgelist_temp(j).z_shift = 0;
        else
            wedgelist_temp(j).z_shift = tiltcom.SHIFT(2);
        end
    end
    

        
    
    
    % Parse dose
    [~,dose_idx] = setdiff(tomolist(i).collected_tilts,tomolist(i).removed_tilts);
    temp_dose = num2cell(tomolist(i).dose(dose_idx));
    [wedgelist_temp.exposure] = temp_dose{:};

    % Get defocus angles
    if def
        if tomolist(i).ctf_determined
            switch size(tomolist(i).determined_defocii,2)
                case 1
                    def_cell = num2cell(tomolist(i).determined_defocii);
                case 3
                    def_cell = num2cell(mean(tomolist(i).determined_defocii(:,1:2),2));
                case 4
                    def_cell = num2cell(mean(tomolist(i).determined_defocii(:,1:2),2));
                    ps_cell = num2cell(tomolist(i).determined_defocii(:,4));
                    [wedgelist_temp.pshift] = ps_cell{:};
            end            
        else
            def_cell = num2cell(ones(n_tilts,1));
        end
        [wedgelist_temp.defocus] = def_cell{:};
    end
    
    w_cell{i} = wedgelist_temp;
end

% Concatenate wedgelist
wedgelist = [w_cell{:}];

% Reorder list
[~,f_idx] = intersect(w_fields(:,1),fieldnames(wedgelist));   % Parse common fields
wedgelist = orderfields(wedgelist,w_fields(sort(f_idx),1));

% Write output
sg_wedgelist_write([subtomo_dir,wedgelist_name],wedgelist);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
