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
% WW 05-2019

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
    data_idx = find(strncmp('data_',star{1},5));
    motl_start_idx = find(strncmp('data_stopgap_motivelist',star{1},23));
    motl_end_idx = find(data_idx>motl_start_idx(1))-1;
    if isempty(motl_end_idx)
        motl_end_idx = n_lines;
    end

    % Find fields in file
    field_idx = find(strncmp('_',star{1},1));
    n_fields = numel(field_idx);

    % Check fields against defined fields
    def_fields = sg_get_motl_fields;    % Load defined fields
    used_fields = false(n_fields,1);    % Used fields in input list
    fields = cell(n_fields,1);          % Fields in input list
    field_order = zeros(n_fields,1);    % Order if input fields
    for i = 1:n_fields
        fields{i} = star{1}{field_idx(i)}(2:end);
        check_idx = strcmp(fields{i},def_fields(:,1));
        if ~any(check_idx)
            error(['ACHTUNG!!! Unsupported motivelist field: ',star{1}{field_idx(i)},'!!!']);
        else
            used_fields(check_idx) = true;
            field_order(check_idx) = i;
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
data_cell = cell(n_fields,n_motls);
c = 1;
for i = 1:numel(motl_idx)
    if motl_idx(i)
        data_cell(:,c) = textscan(star{1}{i+field_idx(end)},fmt);
        c = c+1;
    end
end
clear star


%% Generate struct array

% Sorted fields
[~,sort_idx] = sort(field_order);

% Intialize struct
motl = struct();

% Fill fields
for i = 1:n_fields
    switch def_fields{field_order(i),2}
        case 'str'
            motl.(def_fields{field_order(i),1}) = data_cell(sort_idx(i),:)';
        otherwise
            motl.(def_fields{field_order(i),1}) = [data_cell{sort_idx(i),:}]';
    end
end

clear data_cell

end



