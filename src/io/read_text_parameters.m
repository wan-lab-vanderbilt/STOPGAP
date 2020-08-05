function p = read_text_parameters(rootdir,param_name,fields)
%% read_text_parameters
% Read a generic text parameter file. Only parameters given as input fields
% will be parsed. Inline comments are not supported.
%
% WW 10-2018

%% Initialize 

% Read file
fid = fopen([rootdir,'/',param_name],'r');
text = textscan(fid,'%s\n');
fclose(fid);
text = text{1};

% Number of arguments
n_fields = size(fields,1);


%% Parse parameters

% Initialize struct
p = struct();

% Evaluate parameters
for i = 1:n_fields
    
    % Find field index
    search_param = [fields{i,1},'='];
    idx = strncmpi(text,search_param,numel(search_param));
    
    % Split string
    param = strsplit(text{idx},'=');
    

    % Check param type
    switch fields{i,2}
        case 'str'
            p.(param{1}) = param{2};
        case 'num'
            p.(param{1}) = str2double(param{2});
        case 'boo'
            p.(param{1}) = eval_bool(param{2});
    end
end


