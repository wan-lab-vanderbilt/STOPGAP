function clear_comm_folder(p,o,s,idx)
%% clear_comm_folder
% Clear the comm folder at the start of a STOPGAP run. 
%
% WW 06-2023

%% Clear comm folder


if o.procnum == 1
    
    % Clear comm folder
    system(['rm -rf ',p(idx).rootdir,'/',o.commdir,'/*']);
    
    % Write clear file
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/comm_cleared_',num2str(idx)]);
    
else
    
    % Wait for comm directory to clear
    wait_for_it([p(idx).rootdir,'/',o.commdir],['comm_cleared_',num2str(idx)],s.wait_time);
    
end



