function sg_motl_apply_shifts(input_name,output_name)
%% sg_motl_apply_shifts
% Apply shifts to the original positions in a motivelist.
%
% WW 02-2019

%% Apply shifts


% Read input
motl = sg_motl_read2(input_name);

% Apply shifts
x = motl.orig_x + motl.x_shift;
motl.orig_x = round(x);
motl.x_shift = x - round(x);

y = motl.orig_y + motl.y_shift;
motl.orig_y = round(y);
motl.y_shift = y - round(y);

z = motl.orig_z + motl.z_shift;
motl.orig_z = round(z);
motl.z_shift = z - round(z);

% Write output
sg_motl_write2(output_name,motl);

