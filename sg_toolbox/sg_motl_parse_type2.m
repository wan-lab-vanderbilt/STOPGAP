function motl = sg_motl_parse_type2(motl,idx)
%% sg_motl_parse_type2
% Parse a subset of a read-type2 motivelist using a given input index.
%
% WW 08-2019

%% Parse motl

% Parse fields
fields = fieldnames(motl);
n_fields = numel(fields);

% Parse motl
for i = 1:n_fields
    motl.(fields{i}) = motl.(fields{i})(idx);
end


