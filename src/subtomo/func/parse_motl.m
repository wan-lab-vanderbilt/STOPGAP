function motl = parse_motl(allmotl,idx)
%% parse_motl
% Parse specific entries from a style-2 motivelist. Entires are return in a
% style-1 struct array.
%
% WW 06-2019

%% Parse motl

% Parse fields
fields = fieldnames(allmotl);
n_fields = numel(fields);

% Initialze new struct
motl = struct();

% Fill struct
for i = 1:n_fields    
    motl.(fields{i}) = allmotl.(fields{i})(idx);
end



