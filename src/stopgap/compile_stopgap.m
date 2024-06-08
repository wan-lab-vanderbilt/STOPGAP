function compile_stopgap(target_dir)

% % Clear workspace
% clear all
% close all

% Compile
% target_dir =  '/dest_dir/stopgap_0.7.3/exec/lib/';
target_dir = sg_check_dir_slash(target_dir);
mcc('-R', 'nojvm', '-R', '-nodisplay', '-R', '-singleCompThread', '-R', '-nosplash', '-d', target_dir, '-mv', 'stopgap.m');
system(['chmod +x ',target_dir,'stopgap']);
