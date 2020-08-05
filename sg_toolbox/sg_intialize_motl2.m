function motl = sg_intialize_motl2(n_motls)
%% sg_intialize_motl2
% Initialize an empty motivelist as style-2 struct array.
%
% WW 06-2019

%% Initialize motl

% Get fields
fields = sg_get_motl_fields;
n_fields = size(fields,1);

% Initialize struct
motl = struct();

% Fill struct
for i = 1:n_fields
    
    switch fields{i,3}
        
        case 'int'
            motl.(fields{i}) = zeros(n_motls,1,'int32');
            
        case 'float'
            motl.(fields{i}) = zeros(n_motls,1,'single');
            
        case 'str'
            motl.(fields{i}) = repmat({'A'},n_motls,1);
            
    end
end



