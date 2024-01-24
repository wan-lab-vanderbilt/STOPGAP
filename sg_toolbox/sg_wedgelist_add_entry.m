%% sg_wedgelist_add_entry.m
% A function for generating a stopgap wedgelist entry for a single 
% tomogram.If the output wedgelist already exists, it will be appended.
%
% Minimum parameters include tomogram number, pixelsize, tomogram size, and
% tilt-scheme parameters.
%
% WW 01-2024

%% Inputs

% Tomogram Parameters
t.tomo_num     = 51;      % Tomogram number
t.pixelsize    = 2.776;   % Full pixelsize
t.tomo_x       = 4092;   % Full tomogram X-dimension
t.tomo_y       = 5760;   % Full tomogram Y-dimension
t.tomo_z       = 1188;   % Full tomogram Z-dimension
t.z_shift      = 0;      % Z-shift during tomogram reconstruction

% Tilt-series parameters
min_tilt     = -60;         % Minimum tilt angle
max_tilt     = 60;          % Maximum tilt angle
tilt_step    = 3;           % Tilt step
tilt_scheme  = 'hagen';     % Supported are 'unidirectional', 'bidirectional', and 'hagen'.
tilt_start = 0;            % Starting tilt angle.
tilt_direction = '+';       % Tilting direction from starting tilt.
excluded_tilts = [];        % Excluded tilts from tilt-range. Leave empty '[]' for no removed tilts.
grouping = 3;               % For grouped Hagen scheme collection. Set to 1 for no grouping. 
dose = 3;                   % Dose per tilt in e/A^2.

% Defocus list (Text file containing defocii in sorted order)
def_list_name = 'none';

% Microscope parameters for CTF (Only if defocus list is given)
m.voltage = 300;            % Voltage (keV)
m.amp_contrast = 0.07;      % Amplitude contrast
m.cs = 2.7;                 % Spherical abberation (mm)


% Output name
wedgelistname = 'wedgelist_test.star';


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
            a1 = tilt_start:-tilt_step:min_tilt;
            dose_list(1:numel(a1),1) = a1;
            a2 = bistart+tilt_step:tilt_step:max_tilt;
            dose_list(numel(a1)+1:end,1) = a2;
        elseif tilt_direction == '+'
            a1 = tilt_start:tilt_step:max_tilt;
            dose_list(1:numel(a1),1) = a1;
            a2 = tilt_start-tilt_step:-tilt_step:min_tilt;
            dose_list(numel(a1)+1:end,1) = a2;
        end
    
        
    case 'hagen'
    
        % Initialize indices to track Hagen Scheme
        pos_tilt = tilt_start;
        neg_tilt = tilt_start;
        tilt_idx = 1;
        curr_tilt_direction = tilt_direction;
        pos_done = false;
        neg_done = false;
        dose_list(1,1) = tilt_start;
        
        % Check direction
        switch tilt_direction
            case '+'
                pos_count = 2;
                neg_count = 1;
            case '-'
                pos_count = 1;
                neg_count = 2;

        end

        % Fill Hagen Scheme angles
        while (~pos_done || ~neg_done) && (tilt_idx < n_tilts)
            switch curr_tilt_direction
                case '+'

                    % Check if limit has been reached
                    if (pos_tilt >= max_tilt) || pos_done
                        % Swap direction
                        curr_tilt_direction = '-';
                        continue
                    end

                    % Calculate tilt increments
                    increments = pos_tilt + ((1:grouping)*tilt_step);

                    % Check if increments goes beyond limit
                    lim_idx = increments > max_tilt;
                    if any(lim_idx)
                        pos_done = true;
                        increments = increments(~lim_idx);
                        if isempty(increments)
                            continue
                        end
                    end

                    % Store angles
                    dose_list(tilt_idx+1:tilt_idx+numel(increments),1) = increments;

                    % Store last increment
                    pos_tilt = increments(end);

                    % Update tilt index
                    tilt_idx = tilt_idx+numel(increments);

                    % Check for swap
                    if pos_count == 1
                        pos_count = 2;
                    else
                        pos_count = 1;
                        % Swap direction
                        curr_tilt_direction = '-';
                    end

                case '-'

                    % Check if limit has been reached
                    if (neg_tilt <= min_tilt) || neg_done
                        % Swap direction
                        curr_tilt_direction = '+';
                        continue
                    end

                    % Calculate tilt increments
                    increments = neg_tilt + ((1:grouping)*-tilt_step);

                    % Check if increments goes beyond limit
                    lim_idx = increments < min_tilt;
                    if any(lim_idx)
                        neg_done = true;
                        increments = increments(~lim_idx);
                        if isempty(increments)
                            continue
                        end
                    end

                    % Store angles
                    dose_list(tilt_idx+1:tilt_idx+numel(increments),1) = increments;

                    % Store last increment
                    neg_tilt = increments(end);

                    % Update tilt index
                    tilt_idx = tilt_idx+numel(increments);

                    % Check for swap
                    if neg_count == 1
                        neg_count = 2;
                    else
                        neg_count = 1;
                        % Swap direction
                        curr_tilt_direction = '+';
                    end
            end
        end

        % Check for early termination
        if tilt_idx < n_tilts
            % Crop list
            dose_list = dose_list(1:tilt_idx,:);
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

    
        
    
        
    
        
    
        
    
        