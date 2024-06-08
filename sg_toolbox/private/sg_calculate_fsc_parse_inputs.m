function fsc_param = sg_calculate_fsc_parse_inputs(inputs)
%% sg_calculate_parse_inputs
% Parse inputs for sg_calculate_FSC.
%
% WW 05-2024


%% Initialize

% Reshape inputs
inputs = reshape(inputs,2,[])';

% Get input fields
fsc_fields = sg_calculate_fsc_get_fields();

% Number of target fields
n_fields = size(fsc_fields,1);

% Initialize struct
fsc_param = struct();


%% Parse inputs

% Fill struct
for i = 1:n_fields
    
    % Find index of parameter
    idx = strcmpi(fsc_fields{i,1},inputs(:,1));
    
    % Check input field
    if any(idx)
        % Store field in struct
        fsc_param.(fsc_fields{i,1}) = inputs{idx,2};
    else
        % Store default
        fsc_param.(fsc_fields{i,1}) = fsc_fields{i,3};
    end
    
end

% Evaluate fields
fsc_param = sg_evaluate_field_types(fsc_param,fsc_fields);

% Check for empty fields
for i = 1:n_fields
    if isempty(fsc_param.(fsc_fields{i,1}))
        error(['ACHTUNG !!! ',fsc_fields{i,1},' is a required field!!!']);
    end
end



