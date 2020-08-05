function motl = sg_initialize_motl(n_motls,motl_fields)
%% intialize_motl
% Intitialize a new stopgap motivelist with empty values.
%
% WW 05-2018

%% Generate motl

if nargin == 1
    motl_fields = sg_get_motl_fields;
end

% Initalize struct array
for i = 1:size(motl_fields,1)   
    motl(n_motls).(motl_fields{i,1}) = [];
end
motl = motl';

