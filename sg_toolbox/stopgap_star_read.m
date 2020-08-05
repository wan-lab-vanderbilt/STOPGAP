function [struct_array,data_block] = stopgap_star_read(star_name, parsenum, fieldtypes, data_block)
%% stopgap_star_read
% A function to read a data block from a .star file as a struct array. Only
% data blocks with data arranged in loops is supported.
%
% The parsenum parameter, given as 0 or 1, decides if the function tries to
% determine numeric fields. 
%
% A cell array containing field types can also be given to override numeric
% testing. Field types are: 'str','num','boo' for string, numeric, and
% logical types.
%
% v1: WW 11-2017
% v2: WW 01-2018: Updated numeric parsing; can now properly parse
% comma-separated numeric arrays.
% v3: WW 04-2018: Updated to take in field types
% v4: WW 04-2018: Partial rewrite to check for specific .star formatting
% and to parse specific data blocks
%
% WW 04-2018

%% Check check!!!
if nargin < 3
    data_block = [];
end
if nargin < 3
    fieldtypes = [];
end
if nargin < 2
    parsenum = 1;
end
if (nargin > 4) || (nargin < 1)
    error('Achtung!!! Incorrect number of inputs!!!');
end

if ~isempty(fieldtypes) && (parsenum==1)
    warning('ACHTUNG!!! "fieldtypes" will be used rather than automatic numeric parsing!!!');
end

%% Read format information

% Open .star file
fid = fopen(star_name,'r');
star = textscan(fid, '%s', 'Delimiter', '\n');

% Find target data block
data_idx = find(strncmp(star{1},'data_',5));
n_data = numel(data_idx);
if isempty(data_block) 
    if (n_data > 1)    
        error('ACHTUNG!!! Multiple data blocks detecked!!! Tell me what you want!!!');
    else
        % Parse data name
        data_block = get_uncommented_string(star{1}{data_idx(1)},'#','data_');
    end
else
    % Find target data block
    block_str = ['data_',data_block];
    block_idx = find(strncmp(star{1},block_str,numel(block_str)));
    n_blocks = numel(block_idx);
    if n_blocks > 1
        block_test = false(n_blocks,1);
        for i = 1:n_blocks
            block_test(i) = strcmp(get_uncommented_string(star{1}{block_idx(i)},'#'),block_str);
        end
        if sum(block_test) > 1
            error(['ACHTUNG!!! More than one data block named ',data_block,'!!!']);
        else
            block_idx = block_idx(block_test);
        end
        
        % Isolate data block
        data_idx_idx = find(data_idx == block_idx);
        star{1} = star{1}(data_idx(data_idx_idx):data_idx(data_idx_idx+1)-1);
        
    elseif n_blocks == 0
        error('ACHTUNG!!! Data block not found!!!');
    end                
    
end

% Find loop indices
loop_idx = find(strncmp(star{1},'loop_',5));
if isempty(loop_idx)
    error('ACHTUNG!!! Only loop-type .star files are supported!!!');
elseif numel(loop_idx) > 1
    error('ACHTUNG!!! This function does not support mixed loop and non-loop items!!!');
end

% Find data names
data_name_idx = find(strncmp(star{1},'_',1));
n_fields = numel(data_name_idx);
if any(loop_idx > data_name_idx)
    error('ACHTUNG!!! This function does not support mixed loop and non-loop items!!!');
end
if ~isempty(fieldtypes)
    if numel(fieldtypes) ~= n_fields
        error('ACHTUNG!!! The number of fields does not match input fieldtypes array!!!');
    end
end
fields = cell(n_fields,1);
for i = 1:n_fields
    fields{i} = get_uncommented_string(star{1}{data_name_idx(i)},'#','_');
end

% Find empty lines
empty_lines = cellfun('isempty',star{1});


%% Read data and convert to struct array

% Length of header area
header_length = max(data_name_idx);

% Find indices of data lines
data_idx = find(~empty_lines.*(1:numel(empty_lines))'>(header_length+1));
n_data = numel(data_idx); % Subtract fields, "loop_" and "data_"

% Parse data
data_cell = cell(n_fields,n_data);
for i = 1:n_data
    temp_string = get_uncommented_string(star{1}{data_idx(i)},'#');
    if ~isempty(temp_string)
        data_cell(:,i) = strsplit(temp_string);
    end
end

% Return struct
struct_array = cell2struct(data_cell,fields);


%% Attempt to parse numbers

if (parsenum == 1) && isempty(fieldtypes)
    for i = 1:n_fields
        
        % Test for numbers
        c = {struct_array.(fields{i})};
        test = all(cellfun(@(x) all(ismember(x,'0123456789+-.eEdD,')), c));
        
        if test == 1
            numcell = cellfun(@(x) str2double(strsplit(x,{',',' '})), {struct_array.(fields{i})},'UniformOutput', false);
            [struct_array.(fields{i})] = numcell{:};
        end
    end
end

%% Assign field types from input array

if ~isempty(fieldtypes)    
    for i = 1:n_fields
        
        switch fieldtypes{i}
            case 'num'
               numcell = cellfun(@(x) str2double(strsplit(x,{',',' '})), {struct_array.(fields{i})},'UniformOutput', false);
               [struct_array.(fields{i})] = numcell{:}; 
            case 'boo'
               boocell = num2cell(cellfun(@(x) eval_bool(x),{struct_array.(fields{i})}));
               [struct_array.(fields{i})] = boocell{:};
        end
        
    end
end

end



%% Get uncommented string without whitespace
function uncom_string = get_uncommented_string(input_string,comment_char,starting_string)

if nargin == 2
    start_offset = 0;
else
    start_offset = numel(starting_string);
end

comment_idx = strfind(input_string(start_offset+1:end),comment_char);

if isempty(comment_idx)
    str_end = numel(input_string);
else
    str_end = comment_idx(1)-1+start_offset;
end

uncom_string = strtrim(input_string(start_offset+1:str_end));

end


%% Evaluate boolean
function output = eval_bool(input)

switch input
    case {'0','false',0}
        output = false;
    case {'1','true',1}
        output = true;
end

end