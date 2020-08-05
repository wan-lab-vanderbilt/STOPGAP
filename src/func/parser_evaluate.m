function p = parser_evaluate(p,param)
%% parser_evaluate
% A function to evaluate the non-string inputs of a parameter struct array.
% The 'param' list contains the parameter names in the first row and the
% types in the second row. Types are 'str', 'num', 'boo'.
%
% WW 01-2018

%% Evaluate fields

% Number of rows
n_rows = size(p,1);

% Get fields
fields = fieldnames(p);
n_fields = numel(fields);

% Evaluate
for i = 1:n_fields
    
    % If not empty
    if ~isempty(p(1).(fields{i})) && any(strcmp(param(1,:),fields{i}))
        
        % Find field index
        idx = strcmp(param(1,:),fields{i});
        
        % Evaluate each row for field
        for j = 1:n_rows
            switch param{2,idx}

                % Numeric inputs
                case 'num'
                    if ~isnumeric(p(j).(fields{i}))                        
                        p(j).(fields{i}) = str2double(strsplit(p(j).(fields{i}),{',',' '}));
                    end

                % Boolean input
                case 'boo'
                    switch lower(p(j).(fields{i}))
                        case {'0','false',0}
                            p(j).(fields{i}) = false;
                        case {'1','true',1}
                            p(j).(fields{i}) = true;
                    end
            end
        end
    end
end

