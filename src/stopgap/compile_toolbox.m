function compile_toolbox(target_dir)

% Add sg_toolbox
sg_toolbox_dir = '/dors/wan_lab/home/wanw/research/software/stopgap/0.7.5/sg_toolbox/';
matlab_root = '/usr/local/MATLAB/R2020b/';

% Compile
target_dir = sg_check_dir_slash(target_dir);
mcc('-R', '-nosplash', '-d', target_dir, '-mv', 'sg_toolbox.m', '-a', sg_toolbox_dir, '-a', [matlab_root,'toolbox/matlab/graph2d/']);
system(['chmod +x ',target_dir,'sg_toolbox']);
