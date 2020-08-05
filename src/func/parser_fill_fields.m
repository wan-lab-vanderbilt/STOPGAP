function p = parser_fill_fields(p,param,fields)
%% parser_fill_fields
% A function to fill missing fields with 'blank' parameters. 'p' is the
% struct to be filled, param are the parameter arrays with the field types,
% and fields are the total fields to evaluate.
%
% WW 01-2018

%% Fill missing fields

% Get old fields
old_fields = fieldnames(p);
n_rows = size(p,1);

% Find missing new fields
missing_fields = setdiff(fields,old_fields);

% Fill fields
for i = 1:numel(missing_fields)
    
    % Find field index in parser_param
    idx = strcmp(param(1,:),missing_fields{i});
    
    switch param{2,idx}
        case 'str'
            temp_field = repmat({'none'},n_rows,1);
        case 'num'
            temp_field = repmat({0},n_rows,1);
        case 'boo'
            temp_field = repmat({false},n_rows,1);
    end
    % Fill field
    [p.(missing_fields{i})] = temp_field{:};

end