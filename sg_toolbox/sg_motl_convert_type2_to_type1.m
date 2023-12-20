function new_motl = sg_motl_convert_type2_to_type1(motl)
%% sg_motl_convert_type2_to_type1
% Take a pre-read motivelist and convert the read-type from 2 to 1.
%
% WW 04-2021

%% Convert

% Get field types
fields = sg_get_motl_fields;
n_fields = size(fields,1);

% Intiialize new motivelist
n_motls = numel(motl.motl_idx);
new_motl = sg_initialize_motl(n_motls,fields);

% Fill struct
for i = 1:n_fields
    switch fields{i,2}
        
        case {'num','boo'}
            value = num2cell(motl.(fields{i,1}));
            [new_motl.(fields{i,1})] = value{:};
            
        case 'str'
            [new_motl.(fields{i,1})] = motl.(fields{i,1}){:};
    end
end

    

