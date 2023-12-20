function sg_wedgelist_from_tomolist(tomolist_name,wedgelist_name)
%% sg_wedgelist_from_tomolist
% A function to generate a stopgap wedgelist from a TOMOMAN tomolist.
%
% "tomolist_name" is the input tomolist. "wedgelist_name" is the output
% wedgelist name.
%
% WW 08-2022

% % % % % DEBUG
% tomolist_name = 'tomolist.mat';
% wedgelist_name = 'wedgelist.star';


%% Initialize

% Read tomolist
tomolist = tm_read_tomolist([],tomolist_name);
n_tomos = numel(tomolist);

% Initialize new wedgelist
w_fields = sg_get_wedgelist_fields;
w_cell = cell(n_tomos,1);

% Check for defocus
if all(~[tomolist.ctf_determined])
    def = false;
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
    
    % Parse stack name
    switch tomolist(i).alignment_stack
        case 'unfiltered'
            stack_name = tomolist(i).stack_name;
        case 'dose-filtered'
            stack_name = tomolist(i).dose_filtered_stack_name;
        otherwise
            error([p.name,'ACHTUNG!!! ',process_stack,' is an unsupported stack type!!! Allowed types are either "unfiltered" or "dose-filtered"']);
    end
    [~,name,~] = fileparts(stack_name);
    
    % Parse alignment filenames
    switch tomolist(i).alignment_software
        case 'AreTomo'
            ali_dir = 'AreTomo/';                
        case 'imod'
            ali_dir = 'imod/';                
        otherwise
            error([p.name,'ACHTUNG!!! ',tomolist(i).alignment_software,' is unsupported!!!']);
    end
    tiltcom_name = [tomolist(i).stack_dir,ali_dir,'tilt.com'];
    tlt_name = [ali_dir,name,'.tlt'];
        
    % Read tilt.com        
    tiltcom = tm_imod_parse_tiltcom(tiltcom_name);
    
    
    % Get wedge angles
    tilts = num2cell(dlmread([tomolist(i).stack_dir,tlt_name]));
    n_tilts = numel(tilts);
    [wedgelist_temp(1:n_tilts).tilt_angle] = tilts{:};    

    % Assign parameters
    for j = 1:n_tilts
        wedgelist_temp(j).tomo_num = tomolist(i).tomo_num;
        wedgelist_temp(j).pixelsize = tomolist(i).pixelsize;
        wedgelist_temp(j).voltage = tomolist(i).voltage;
%         wedgelist_temp(j).amp_contrast = tomolist(i).ctf_parameters.famp;
%         wedgelist_temp(j).cs = tomolist(i).ctf_parameters.cs;
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
            def_cell = num2cell(zeros(n_tilts,1));
        end
        [wedgelist_temp.defocus] = def_cell{:};
        
        % Store amplitude contrast
        amp_cell = num2cell(ones(n_tilts,1).*tomolist(i).ctf_parameters.famp);
        [wedgelist_temp.amp_contrast] = amp_cell{:};
        % Store spherical abberation
        cs_cell = num2cell(ones(n_tilts,1).*tomolist(i).ctf_parameters.cs);
        [wedgelist_temp.cs] = cs_cell{:};
        
    end
    
    w_cell{i} = wedgelist_temp;
end

% Concatenate wedgelist
wedgelist = [w_cell{:}];

% Reorder list
[~,f_idx] = intersect(w_fields(:,1),fieldnames(wedgelist));   % Parse common fields
wedgelist = orderfields(wedgelist,w_fields(sort(f_idx),1));

% Write output
sg_wedgelist_write(wedgelist_name,wedgelist);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
