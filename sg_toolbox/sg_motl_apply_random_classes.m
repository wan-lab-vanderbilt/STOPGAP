function new_motl = sg_motl_apply_random_classes(motl,n_classes,output_name)
%% sg_motl_apply_random_classes
% Apply random classes to a motivelist. This results in a motivelist with 1
% entry per class. Classes are assigned from 1 to n_classes.
%
% If an output_name is supplied, the new motl is written out. 
%
% WW 11-2018

%% Check check

% Check input
if ischar(motl)
    motl = sg_motl_read2(motl);
else
    motl_type = sg_motl_check_read_type;
    if motl_type == 1
        motl = sg_motl_convert_type1_to_type2(motl);
    end
end

% Check for output
if nargin == 3
    write_out = true;
end

% Check number of inputs
if nargin < 2 
    error('ACHTUNG!!! Invalid number of inputs!!!');
end


%% Apply random classes

% Number of motls
n_motls = numel(motl.motl_idx);

% Random class array
class_array = repmat(1:n_classes,[1,ceil(n_motls/n_classes)]);
rand_idx = randperm(n_motls);
rand_classes = class_array(rand_idx);

% Apply to motl
motl.class = rand_classes';

%% Check output

if write_out
    sg_motl_write2(output_name,motl);
end



