function compile_parser(target_dir)

% % Clear workspace
% clear all
% close all

% Compile
target_dir = sg_check_dir_slash(target_dir);
mcc('-R', 'nojvm', '-R', '-nodisplay', '-R', '-singleCompThread', '-R', '-nosplash', '-d', target_dir, '-mv', 'stopgap_parser.m');
system(['chmod +x ',target_dir,'stopgap_parser']);
