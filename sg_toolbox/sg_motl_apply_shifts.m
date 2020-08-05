function sg_motl_apply_shifts(input_name,output_name)
%% sg_motl_apply_shifts
% Apply shifts to the original positions in a motivelist.
%
% WW 02-2019

%% Apply shifts

% Read input
motl = sg_motl_read(input_name);

% Apply shifts
motl = sg_motl_fill_field(motl,'orig_x',[motl.orig_x] + round([motl.x_shift]));
motl = sg_motl_fill_field(motl,'x_shift',round([motl.x_shift]) - [motl.x_shift]);

motl = sg_motl_fill_field(motl,'orig_y',[motl.orig_y] + round([motl.y_shift]));
motl = sg_motl_fill_field(motl,'y_shift',round([motl.y_shift]) - [motl.y_shift]);

motl = sg_motl_fill_field(motl,'orig_z',[motl.orig_z] + round([motl.z_shift]));
motl = sg_motl_fill_field(motl,'z_shift',round([motl.z_shift]) - [motl.z_shift]);


% Write output
sg_motl_write(output_name,motl);


