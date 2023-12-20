function dir_name = sg_check_dir_slash(dir_name)
%% sg_check_dir_slash
% Check if input directory name has a slash at the end. If it doesn't, one
% is appended. 
%
% WW 10-2022

%% Check check

if isempty(dir_name)
    return
elseif ~strcmp(dir_name(end),'/')
    dir_name = [dir_name,'/'];
end



