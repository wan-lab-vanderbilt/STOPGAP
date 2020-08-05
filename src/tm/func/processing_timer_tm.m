function t = processing_timer_tm(t,action,p,o,idx,mode)
%% processing_timer_tm
% A function for timing processes during template matching. Mode refers to 
% the processing mode. Actions are either 'start' or 'end'; ending also
% triggers the writing of a timing file to the temp folder. 
%
% WW 03-2019

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
        name = [p(idx).rootdir,'/',o.tempdir,'/timer_',mode,'_',num2str(p(idx).tomo_num),'_',num2str(o.procnum)];
        dlmwrite(name,proc_time);
        
end



