function check = sg_check_empty_field(input)
%% sg_check_empty_field
% Check if a parser field is either empty or set to none. Returns 'true' is
% field is unset.
%
% WW 05-2018

if ~isempty(input) && ~strcmp(input,'none')
    check = false;
else
    check = true;
end

    
