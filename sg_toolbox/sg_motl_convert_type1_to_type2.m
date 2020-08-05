function new_motl = sg_motl_convert_type1_to_type2(motl)
%% sg_motl_convert_type1_to_type2
% Take a pre-read motivelist and convert the read-type from 2 to 1.
%
% WW 09-2019

%% Convert

% Get field types
fields = sg_get_motl_fields;
n_fields = size(fields,1);

% Intiialize new motivelist
new_motl = struct();

% Fill struct
for i = 1:n_fields
    switch fields{i,2}
        case {'num','boo'}
            new_motl.(fields{i,1}) = [motl.(fields{i,1})]';
        case 'str'
            new_motl.(fields{i,1}) = {motl.(fields{i,1})}';
    end
end

    

