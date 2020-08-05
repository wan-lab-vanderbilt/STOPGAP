function sg_motl_singleentry_to_multientry(motl_name,output_name,n_classes,classes)
%% sg_motl_singleentry_to_multientry
% Take a single-entry motivelist and duplicate entries to produce a
% multi-entry mutlireference motivelist. If "classes" is given, classes for 
% each subtomogram will assigned those, otherwise classes are set form 1 to
% n_ref. 
%
% WW 09-2019


%% Check check
if nargin == 4
    if numel(classes) ~= n_classes
        error('ACHTUNG!!! number of input "classes" must match "n_classes"!!!');
    end
elseif nargin == 3
    classes = 1:n_classes;
elseif nargin ~= 3 
    error('ACHTUNG!!! Invalid number of inputs!!!');
end

%% Initialize

% Read motivleist
motl = sg_motl_read2(motl_name);
n_motls = numel(motl.motl_idx);

% Check type
if sg_motl_check_type(motl) == 3
    error('ACHTUNG!!! Inmput motivelist is already a multientry motivelist!!!');
end

% Get fields
fields = sg_get_motl_fields();
n_fields = size(fields,1);

% New length
new_length = n_motls.*n_classes;

%% Generate new motivelist

% Initialize new motivelist
new_motl = struct();

% Duplitcate fields
for i = 1:n_fields
    
    % Duplicate field
    temp_field = reshape(repmat(motl.(fields{i,1}),1,n_classes)',new_length,1);
            
    % Store field
    new_motl.(fields{i,1}) = temp_field;
    
end


% Apply new classes
new_motl.class = repmat(classes(:),[n_motls,1]);

% Write output
sg_motl_write2(output_name,new_motl);


