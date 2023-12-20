function t = tps_processing_timer(t,action,p,o,idx,mode)
%% tps_processing_timer
% A function for timing processes during tube power spectrum calculation. 
% Mode refers to the processing mode. Actions are either 'start' or 'end'; 
% ending also triggers the writing of a timing file to the temp folder. 
%
% WW 10-2022

%% Check check

% Check input parameters
if nargin < 3
    if ~strcmp(action,'start')
        error('ACHTUNG!!! Insufficent number of input parameters!!!');
    end
end

    

%% Timer

switch action
    
    case 'start'
        
        % Initialize timer
        t.timer = tic;
        
    case 'end'
        
        % Get processing time
        proc_time = toc(t.timer);
        
        % Write time
        name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(idx),'_',num2str(o.procnum)];
        dlmwrite(name,proc_time);
        
end



