%% eval_bool.m
% A function for evaulating string/numeric inputs as booleans.
%
% WW 06-2018

%% Evaluate boolean
function output = eval_bool(input)

switch input
    case {'0','false',0}
        output = false;
    case {'1','true',1}
        output = true;
end

end 


