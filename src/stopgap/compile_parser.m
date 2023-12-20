function compile_parser()

% Clear workspace
clear all
close all

% Compile
target_dir =  '/dest_dir/stopgap_0.7.3/exec/lib/';
mcc('-R', 'nojvm', '-R', '-nodisplay', '-R', '-singleCompThread', '-R', '-nosplash', '-d', target_dir, '-mv', 'stopgap_parser.m');
system(['chmod +x ',target_dir,'stopgap_parser']);
