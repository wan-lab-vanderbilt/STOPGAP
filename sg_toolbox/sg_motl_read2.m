function motl = sg_motl_read2(motl_name,no_header)
%% sg_motl_read
% A function for reading a .star file, stopgap-formatted motive list. 
%
% This function has a number of requirements, including no comments in the
% data setction and no comments on empty lines. This is less robust than
% 'stogap_star_read' but is subsantially faster.
%
% Output struct arrays are sets of arrays for each field; while not that
% intuitive, this is required to save MATLAB overhead space, which is
% unwieldy large for large datasets.
%
% WW 03-2021

%% Check check

if nargin == 1
    no_header = false;
end


%% Read text

% Open .star file
fid = fopen(motl_name,'r');
if fid == -1
    error(['ACHTUNG!!! Error opening ',motl_name]);
end

% Read text
star = textscan(fid, '%s', 'Delimiter', '\n');
n_lines = size(star{1},1);

% Close file
fclose(fid);


%% Find fields

if no_header
    
     def_fields = sg_get_motl_fields;    % Load defined fields
     n_fields = size(def_fields,1);
     field_order = 1:n_fields;
     field_idx = 0;
     motl_end_idx = n_lines;
     
else
    
    
    % Find start and end of stopgap_motivelist field
    data_idx = find(strncmp('data_',star{1},5));                                % Find the first data field
    motl_start_idx = find(strncmp('data_stopgap_motivelist',star{1},23));       % Find where the motivelist data starts
    motl_end_idx = find(data_idx>motl_start_idx(1),1)-1;
    if isempty(motl_end_idx)
        motl_end_idx = n_lines;
    end

    % Find fields in file
    field_idx = find(strncmp('_',star{1},1));   % Fields start with '_'
    n_fields = numel(field_idx);

    % Check fields against defined fields
    def_fields = sg_get_motl_fields;    % Load defined fields
    used_fields = false(n_fields,1);    % Used fields in input list
    fields = cell(n_fields,1);          % Fields in input list
    field_order = zeros(n_fields,1);    % Order if input fields
    for i = 1:n_fields
        fields{i} = star{1}{field_idx(i)}(2:end);           % Parse field
        check_idx = strcmp(fields{i},def_fields(:,1));      % Get index in the defined field list
        if ~any(check_idx)
            error(['ACHTUNG!!! Unsupported motivelist field: ',star{1}{field_idx(i)},'!!!']);
        else
            used_fields(check_idx) = true;  % In the defined order
            field_order(check_idx) = i;     % Maps file order to defined order
        end
    end

    % Issue warnings on missing fields
    for i = 1:n_fields
        if ~used_fields(i)
            warning(['ACHTUNG!!! Unset motivelist field: ',def_fields{i}]);
        end
    end
    
end




%% Parse data

% Build formatting string
fmt_cell = cell(n_fields,1);
for i = 1:n_fields
    switch def_fields{field_order(i),3}
        case 'str'
            fmt_cell{i} = '%c ';
        case 'int'
            fmt_cell{i} = '%d ';
        case 'float'
            fmt_cell{i} = '%f ';
        case 'boo'
            fmt_cell{i} = '%d ';
    end      
end
fmt = [fmt_cell{:}];


% Motivelist entry indices
motl_idx = cellfun(@(x) ~isempty(x), star{1}(field_idx(end)+1:motl_end_idx));
n_motls = sum(motl_idx);

% Initialze motivelist
motl = sg_initialize_motl2(n_motls);

% Parse through star cell
c = 1;  % Counter for index in motl struct
for i = 1:numel(motl_idx)
    
    % Check for empty line
    if motl_idx(i)

        % Parse line into temporary cell
        temp_cell = textscan(star{1}{i+field_idx(end)},fmt);
        
        % Fill motl
        for j = 1:n_fields
            
            % No Header
            if no_header
                
                switch def_fields{field_order(j),3}
                    case 'str'
                        motl.(def_fields{j,1}){c} = temp_cell{j};
                    otherwise
                        motl.(def_fields{j,1})(c) = temp_cell{j};
                end
                
            else
                
                switch def_fields{field_order(j),3}
                    case 'str'
                        motl.(fields{field_order(j)}){c} = temp_cell{j};
                    otherwise
                        motl.(fields{field_order(j)})(c) = temp_cell{j};
                end
            end
            
        end
        
        % Increment counter
        c = c+1;
        
    end
end
clear star

end



