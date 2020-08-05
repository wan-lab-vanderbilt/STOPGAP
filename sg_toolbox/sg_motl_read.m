function motl = sg_motl_read(motl_name)
%% sg_motl_read
% A function for reading a .star file, stopgap-formatted motive list. 
%
% This function has a number of requirements, including no comments in the
% data setction and no comments on empty lines. This is less robust than
% 'stogap_star_read' but is subsantially faster.
%
% WW 05-2018


%% Read text file
disp(['Reading ',motl_name,'...']);

% Open .star file
fid = fopen(motl_name,'r');
star = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
n_lines = size(star{1},1);

%% Find indices

% Find start and end of stopgap_motivelist field
data_idx = find(strncmp('data_',star{1},5));
motl_start_idx = find(strncmp('data_stopgap_motivelist',star{1},23));
motl_end_idx = find(data_idx>motl_start_idx(1))-1;
if isempty(motl_end_idx)
    motl_end_idx = n_lines;
end

% Find fields
fields = sg_get_motl_fields;
n_fields = size(fields,1);
field_idx = find(strncmp('_',star{1},1));
if n_fields ~= numel(field_idx);
    error('ACHTUNG!!! Unsupported .star format!!! Number of fields do not match expected number!!!');
end

%% Parse data

% Build formatting string
fmt_cell = cell(n_fields,1);
field_order = zeros(n_fields,1);
for i = 1:n_fields
    % Index of target field in .star file
    temp_idx = strncmp(['_',fields{i,1}],star{1}(field_idx),numel(fields{i,1})+1);
    if isempty(temp_idx)
        error(['ACHTUNG!!! ',fields{i,1},' is empty!!!']);
    elseif sum(temp_idx) > 1
        error(['ACHTUNG!!! ',fields{i,1},' occurs more than once!!!']);
    else
        switch fields{i,3}
            case 'str'
                fmt_cell{temp_idx} = '%c ';
            case 'int'
                fmt_cell{temp_idx} = '%d ';
            case 'float'
                fmt_cell{temp_idx} = '%f ';
            case 'boo'
                fmt_cell{temp_idx} = '%d ';
        end
    end
    field_order(temp_idx) = i;
end
fmt = [fmt_cell{:}];
fmt = fmt(1:end-1);

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

% Resort data cell
data_cell = data_cell(field_order,:);

% Convert to struct array
motl = cell2struct(data_cell,fields(:,1));
disp([motl_name, ' read!!!1!']);

    
end



