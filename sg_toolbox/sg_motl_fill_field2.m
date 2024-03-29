function motl = sg_motl_fill_field2(motl,field,value)
%% sg_motl_fill_field2
% A function to fill a type-2 motl field with given values. The values must 
% either have the same dimensions of the motl or have a single value. In 
% the case of a single value, this value as assigned to all fields.
%
% The given fields are checked against the default fields and types are
% enforced.
%
% WW 04-2021

%% Check check

n_motls = numel(motl.motl_idx);
n_values = numel(value);

if (n_values ~= n_motls) && (n_values ~= 1)
    error('ACHTUNG!!! Number of values is not 1 and does not match number of motl entries!!!');
end

% Number of repeats
if n_values ~= n_motls
    rep_val = n_motls;
else 
    rep_val = 1;
end



%% If non-cell input, parse and store

% Get fields
motl_fields = sg_get_motl_fields;
f_idx = strcmp(field,motl_fields(:,1));

switch motl_fields{f_idx,3}
    
    case 'float'
        
        if isnumeric(value) || islogical(value)
            value = repmat(single(value),[rep_val,1]);
        elseif ischar(value)
            error('ACHTUNG!!! You are trying to store strings into a "float" field!!!');
        end
        
    case 'int'
        
        if isnumeric(value) || islogical(value)
            value = repmat(int32(value),[rep_val,1]);
        elseif ischar(value)
            error('ACHTUNG!!! You are trying to store strings into an "int" field!!!');
        end
            
    case 'str'
        
        if isnumeric(value) || islogical(value)
            value = repmat(cellstr(num2str(value(:))),[rep_val,1]);
        elseif ischar(value)
            if n_values ~= n_motls
                value = repmat({value},[rep_val,1]);
            else
                value = cellstr(value(:));
            end        
        elseif iscell(value)
            num_idx = cellfun(@(x) isnumeric(x) | islogical(x),value);
            if any(num_idx)
                value(num_idx) = strsplit(num2str([value{num_idx}]));
            end
            value = repmat(value,[rep_val,1]);
        end
        
end

% Store value
motl.(field) = value;
