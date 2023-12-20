function timings = sg_diag_read_ali_timings(ali_timings_filename)
%% sg_diag_read_ali_timings
% A function for reading the STOPGAP subtomogram averaging ali_timings
% diagnostic files into a struct array.
%
% WW 10-2022

%%%% DE
%% Read file

raw_timings = csvread(ali_timings_filename);

