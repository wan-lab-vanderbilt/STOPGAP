function s = sg_evaluate_field_types(s, field_types)
%% evaulte_field_types
% A function for evaluating the types of fields within a struct array. 
%
% WW 05-2018

%% Evaluate

% Get struct fields
fields = fieldnames(s);
n_fields = numel(fields);


% Evaluate fields
for i = 1:n_fields
    
    idx = strcmp(fields{i},field_types(:,1));
    
    if all(idx==false)
    
        warning(['ACHTUNG!!! Input struct has extra field "',fields{i},'"!!! Extra field removed!!!']);
        s = rmfield(s,fields{i});
        
    else
        switch field_types{idx,2}

            case 'num' 
                
                % Check if conversion is needed
                if isnumeric(s(1).(fields{i}))
                    continue
                end
                
                % Check for comma for array input
                comma_test = cellfun(@(x) strfind(x,','), {s.(fields{i})},'UniformOutput', false);
                if ~isempty(comma_test)
                    % Convert to numerical array
                    numcell = cellfun(@(x) str2num(x), {s.(fields{i})},'UniformOutput', false); %#ok<ST2NM>
                else
                    % Convert to number
                    numcell = cellfun(@(x) str2double(x), {s.(fields{i})},'UniformOutput', false);
                end
                % Store values
                [s.(fields{i})] = numcell{:};

            case 'boo'
                
                % Check if conversion is needed
                if islogical(s(1).(fields{i}))
                    continue
                end
                
                boocell = num2cell(cellfun(@(x) sg_eval_bool(x),{s.(fields{i})}));
                [s.(fields{i})] = boocell{:};
        end
    end
end





