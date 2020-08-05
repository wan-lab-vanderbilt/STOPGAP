function motl = sg_initialize_motl2(n_motls,motl_fields)
%% sg_initialize_motl2
% Intitialize a new stopgap motivelist with empty values.
%
% WW 05-2018

%% Generate motl

if nargin == 1
    motl_fields = sg_get_motl_fields;
end
n_fields = size(motl_fields,1);

% Initalize struct array
motl = struct();

% Initialize fields
for i = 1:n_fields
    switch motl_fields{i,3}
        case 'int'
            motl.(motl_fields{i,1}) = zeros(n_motls,1,'int32');
        case 'float'
            motl.(motl_fields{i,1}) = zeros(n_motls,1,'single');
        case 'str'
            motl.(motl_fields{i,1}) = repmat({'A'},n_motls,1);
        case 'boo'
            motl.(motl_fields{i,1}) = false(n_motls,1);
    end
end
    
