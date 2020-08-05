%% sg_wedgelist_add_entry.m
% A function for generating a stopgap wedgelist entry for a single 
% tomogram.If the output wedgelist already exists, it will be appended.
%
% Minimum parameters include tomogram number, pixelsize, tomogram size, and
% tilt-scheme parameters.
%
% WW 06-2018

%% Inputs

% Tomogram Parameters
t.tomo_num     = 1;      % Tomogram number
t.pixelsize    = 4.21;   % Full pixelsize
t.tomo_x       = 3712;   % Full tomogram X-dimension
t.tomo_y       = 3712;   % Full tomogram Y-dimension
t.tomo_z       = 1856;   % Full tomogram Z-dimension
t.z_shift      = 0;      % Z-shift during tomogram reconstruction

% Tilt-series parameters
min_tilt     = -50;         % Minimum tilt angle
max_tilt     = 68;          % Maximum tilt angle
tilt_step    = 2;           % Tilt step
tilt_scheme  = 'hagen';     % Supported are 'unidirectional', 'bidirectional', and 'hagen'.
bi_start = 10;               % Starting tilt for bidirectional scheme. Ignore otherwise.
tilt_direction = '+';       % Tilting direction from starting tilt.
excluded_tilts = [];        % Excluded tilts from tilt-range. Leave empty '[]' for no removed tilts.
dose = 0;                   % Dose per tilt in e/A^2.

% Defocus list (Text file containing defocii in sorted order)
def_list_name = 'none';

% Microscope parameters for CTF (Only if defocus list is given)
m.voltage = 300;            % Voltage (keV)
m.amp_contrast = 0.07;      % Amplitude contrast
m.cs = 2.7;                 % Spherical abberation (mm)


% Output name
wedgelistname = 'wedgelist.star';


%% Generate dose list

n_tilts = numel(min_tilt:tilt_step:max_tilt);


% Initialize dose_list
dose_list = zeros(n_tilts,2);
% Fill dose column
dose_list(:,2) = (1:n_tilts).*dose;

switch tilt_scheme
    
    case 'unidirectional'    
        
        % Calculate angle list
        if tilt_direction == '-'
            dose_list(:,1) = min_tilt:tilt_step:max_tilt;
        elseif tilt_direction == '+'
            dose_list(:,1) = fliplr(min_tilt:tilt_step:max_tilt);
        end
    
    case 'bidirectional'
        
        % Calculate angle list
        if tilt_direction == '-'
            a1 = bi_start:-tilt_step:min_tilt;
            dose_list(1:numel(a1),1) = a1;
            a2 = bistart+tilt_step:tilt_step:max_tilt;
            dose_list(numel(a1)+1:end,1) = a2;
        elseif tilt_direction == '+'
            a1 = bi_start:tilt_step:max_tilt;
            dose_list(1:numel(a1),1) = a1;
            a2 = bi_start-tilt_step:-tilt_step:min_tilt;
            dose_list(numel(a1)+1:end,1) = a2;
        end
    
        
    case 'hagen'
        if (abs(min_tilt) == abs(max_tilt)) % Hagen scheme
    
            t_idx = 2; % Tilt index
            m_idx = 1; % Multiple

            % Fill tilt amplitudes
            for i = 1:floor(n_tilts/2)
                dose_list(t_idx:t_idx+1,1) = [m_idx;m_idx].*tilt_step;
                t_idx = t_idx+2;
                m_idx = m_idx+1;
            end


            if tilt_direction == '-'
                t_idx = 1;
                steps = floor(n_tilts/2);
            elseif tilt_direction == '+'
                t_idx = 3;
                steps = floor(n_tilts/2)-1;
            end
            n = -1;

            for i = 1:steps
                dose_list(t_idx:t_idx+1,1) = dose_list(t_idx:t_idx+1,1).*n;
                t_idx = t_idx+2;
                n = n*-1;
            end

            if tilt_direction == '-'
                dose_list(end,1) = dose_list(end,1)*-1;
            end
        end
    
end


%% Remove excluded tilts and resort tilts and exposures

% Remove excluded tilts
if ~isempty(excluded_tilts)
    [~,idx] = setdiff(dose_list(:,1),excluded_tilts);
    dose_list = dose_list(idx,:);
end

% Resort lists
sort_dose_list = sortrows(dose_list,1);
n_tilts = size(sort_dose_list,1);


%% Generate new wedgelist

% Intialize wedgelist
wedgelist = struct();
wedgelist(n_tilts,1).tomo_num = t.tomo_num;

% Fill tomogram parameters
tomo_fields = fieldnames(t);
for i = 1:numel(tomo_fields)    
    temp_cell = num2cell(repmat(t.(tomo_fields{i}),n_tilts,1));
    [wedgelist.(tomo_fields{i})] = temp_cell{:};
end


% Fill microscope parameters
m_fields = fieldnames(m);
for i = 1:numel(m_fields)    
    temp_cell = num2cell(repmat(m.(m_fields{i}),n_tilts,1));
    [wedgelist.(m_fields{i})] = temp_cell{:};
end

% Fill tilts
temp_cell = num2cell(sort_dose_list(:,1));
[wedgelist.tilt_angle] = temp_cell{:};

% Fill exposures
if dose ~= 0
    temp_cell = num2cell(sort_dose_list(:,2));
    [wedgelist.exposure] = temp_cell{:};
end

% Fill defocii
if ~strcmp(def_list_name,'none')
    defocii = num2cell(dlmread(def_list_name));
    [wedgelist.defocus] = defocii{:};
end


%% Write/Append wedgelist

if exist(wedgelistname,'file')
    old_wedgelist = stopgap_star_read(wedgelistname);
    wedgelist = cat(1,old_wedgelist,wedgelist);
end

sg_wedgelist_write(wedgelistname,wedgelist);

    
        
    
        
    
        
    
        
    
        