function [motl, motl_type, classes, n_classes, n_entries, n_idx] = sg_read_convert_motl(input)
%% sg_read_convert_motl
% Read motivelist or check and convert motivelist to type-2 and parse the
% relevent parameters.

% Read or convert motl
if ischar(input)
    motl = sg_motl_read2(input);
else
    r_type = sg_motl_check_read_type(input);
    switch r_type
        case 1
            motl = sg_motl_convert_type1_to_type2(input);
        case 2
            motl = input;
    end
end

% Parse parameters
motl_type = sg_motl_check_type(motl);
classes = unique(motl.class);
n_classes = numel(classes);
n_entries = numel(motl.motl_idx);
n_idx = numel(unique(motl.motl_idx));

end
