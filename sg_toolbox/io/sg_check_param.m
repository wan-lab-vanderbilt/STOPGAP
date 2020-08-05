function check = sg_check_param(array,field)
%% sg_check_param
% Check if struct contains field, and if it does, is it empty or 'none'.
%
% WW 05-2018

%% Check check!!1!

check = false;

if isfield(array,field)
    if ~isempty(array.(field)) & ~strcmp(array.(field),'none')
        if islogical(array.(field))
            check = array.(field);
        else
            check = true;
        end
    end
end
