function p = read_parameters(rootdir,param_name)
%% read_parameters
% Read parameters for subtomogram extraction
%
% WW 08-2018


%% Initialize 

% Read file
fid = fopen([rootdir,'/',param_name],'r');
text = textscan(fid,'%s');
fclose(fid);
text = text{1};

% Number of arguments
n_arg = numel(text);

% Split text fields
inputs = cell(n_arg,2);
for i = 1:n_arg
    inputs(i,:) = strsplit(text{i},'=');
end

% Get fields
fields = get_fields;
n_fields = size(fields,1);

%% Parse parameters

% Initialize struct
p = struct();

% Evaluate parameters
for i = 1:n_fields

    
    % Argument index
    input_idx = find(strcmp(fields(i,1),inputs(:,1)),1);
    
    % Try to store field
    if isempty(input_idx)
        if strcmp(fields{i,3},'req')
            if isempty(fields{i,4})
                error(['ACHTUNG!!! ',fields{i,1},' is a required parameter!!!']);
            else
                temp_param = fields{i,4};
            end
        else
            continue
        end
    else
        temp_param = inputs{input_idx,2};
    end

    % Check param type
    switch fields{i,2}
        case 'str'
            p.(fields{i,1}) = temp_param;
        case 'num'
            p.(fields{i,1}) = str2double(temp_param);
    end
end




