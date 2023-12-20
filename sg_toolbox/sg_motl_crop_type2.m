function crop_motl = sg_motl_crop_type2(motl,idx)
%% sg_motl_crop_type2
% Crop a portion of a type2-read motivelist based on input indices.
%
% WW 03-2021

%% Crop Motivelist

% Get fields
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);

% Initialize new struct
crop_motl = sg_initialize_motl2(numel(idx),motl_fields);

% Crop old motl
for i = 1:n_fields
    
    crop_motl.(motl_fields{i,1}) = motl.(motl_fields{i,1})(idx);
    
end





