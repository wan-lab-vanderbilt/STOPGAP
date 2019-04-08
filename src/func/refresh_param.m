function [p,idx] = refresh_param(rootdir,paramfilename,p,idx)
%% refresh_param
% A function to refreshing a parameter file, i.e. reading in a new
% parameter file and determining the current index.
%
% WW 11-2017

%% Refresh!!!

% Store old parameters for determining new index
old_iteration = p(idx).iteration;
old_subtomo_mode = p(idx).subtomo_mode;



% Read parameter file
try
    p = will_star_read([rootdir,'/',paramfilename]);
catch
    error([nn,'Achtung!!!! Error reading parameter file: ',paramfilename]);
end
% Convert logical fields
l_fields = {'completed_ali','completed_p_aver','completed_f_aver'};
for i = 1:numel(l_fields)
    l = num2cell(cellfun(@(x) logical(x),{p.(l_fields{i})}));
    [p.(l_fields{i})] = l{:};
end



