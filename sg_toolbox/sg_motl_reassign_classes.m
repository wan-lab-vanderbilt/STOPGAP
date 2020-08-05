function motl = sg_motl_reassign_classes(motl,class_assignments)
%% sg_motl_reassign_classes
% A function to reassign classes in a motivelist. Class assignments are
% given as a Nx2 vector where each row contains the old class in column 1
% and the new class in column 2. 
%
% WW 12-2019

%% Check check

% Check input motl
read_type = sg_motl_check_read_type(motl);

% Check assignment dimensions
if size(class_assignments,2) ~= 2
    error('ACHTUNG!!! class_assignments are expected as a Nx2 vector!!!');
end


%% Reassign

% Parse old classes
old_class = reshape([motl.class],[],1);
n_motl = numel(old_class);

% Reassign classes
new_class = zeros(n_motl,1,'int32');
for i = 1:size(class_assignments,1)
    temp_idx = old_class == class_assignments(i,1);
    new_class(temp_idx) = class_assignments(i,2);
end
    

% Store new classes
switch read_type    
    case 1
        motl = sg_motl_fill_field(motl,'class',new_class);
    case 2
        motl.class = new_class;
end


