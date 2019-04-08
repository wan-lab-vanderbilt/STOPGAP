function stopgap_kontrolleur(rootdir,paramfilename,total_cores, submit_cmd)
%% stopgap_kontrolleur
% A function to watch the progress of a 'stopgap' subtomogram averaging 
% job, update the parameter file, and write completion files to move the
% subtomogram averaging job along. 
%
% The environment requires 'listdir' to be on path.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to add options to update core numbers. 
%
% WW 01-2018

% % % DEBUG
rootdir = '/fs/pool/pool-EMpub/4Wan/fromSaikat/';
paramfilename = 'param.star';
total_cores = 256;

%% Initialize
if ischar(total_cores); total_cores = eval(total_cores); end

ali_modes = {'ali_singleref', 'ali_multiclass', 'ali_multiref'};
avg_modes = {'avg_singleref', 'avg_multiclass', 'avg_multiref'};


% Read parameter file
[p,idx] = update_param(rootdir,paramfilename);
if isempty(idx)
    error('ACHTUNG!!! All jobs in param file are finished!!!');
end

% Check for open jobs
open_jobs = ([p.completed_f_aver]==false);  % Jobs to be run...
if all(~open_jobs)  % If all jobs are finished...
    error('ACHTUNG!!! All jobs in param file are finished!!!');
end

% Check cores
if any([p(open_jobs).total_cores]~=total_cores)
    
    % Issue warning
    err_idx = find(([p.total_cores]~=total_cores) & open_jobs);
    n_err = numel(err_idx);
    err_str = strjoin(arrayfun(@(x) num2str(x),err_idx,'UniformOutput',false),',');
    
    % Warning for core number mismatch
    warn_cores = 0;
    
    while warn_cores == 0
        warning(['ACHTUNG!!! Mismatch in total_cores in the following job indices: [',err_str,']  !!!1!']);

        % Fix cores?
        fix_cores = input('Would you like me to I fix your mistakes??? (y/n) \n','s');
        switch lower(fix_cores)
            case 'n'
                exit

            case 'y'
                warn_cores = 1;
                
                wait_ali_cores = 0;
                while wait_ali_cores == 0
                    ali_cores = input('Alright then... Number of alignment cores (n_cores_ali)??? \n','s');

                    % Test for numeric input
                    test_ali_cores = all(ismember(ali_cores,'0123456789'));

                    % Check against total cores
                    if test_ali_cores  
                        ali_cores = str2double(ali_cores);
                        if ali_cores > total_cores
                            warning(['ACHTUNG!!! The number of cores cannot be bigger than the total number of cores (',num2str(total_cores),')!!!']);
                        else
                            wait_ali_cores = 1;
                        end
                    else
                        warning('ACHTUNG!!! Invalid input!!! Number of alignment cores must be given as an integer!!!')
                    end
                end

                wait_aver_cores = 0;
                while wait_aver_cores == 0
                    aver_cores = input('OK, and now the number of averaging cores (n_cores_aver)??? \n','s');
                    test_avg_cores = all(ismember(aver_cores,'0123456789'));
                    if test_avg_cores
                        aver_cores = str2double(aver_cores);
                        if aver_cores > total_cores
                            warning(['ACHTUNG!!! The number of cores cannot be bigger than the total number of cores (',num2str(total_cores),')!!!']);
                        else
                            wait_aver_cores = 1;
                        end
                    else
                        warning('ACHTUNG!!! Invalid input!!! Number of averaging cores must be given as an integer!!!')
                    end
                end

                % Update settings
                n_total_cores = num2cell(total_cores.*ones(1,n_err));            
                [p(err_idx).total_cores] = n_total_cores{:};
                n_cores_ali = num2cell(ali_cores.*ones(1,n_err));            
                [p(err_idx).n_cores_ali] = n_cores_ali{:};
                n_cores_aver = num2cell(aver_cores.*ones(1,n_err));            
                [p(err_idx).n_cores_aver] = n_cores_aver{:};

                % Rewrite param file
                will_star_write(p,[rootdir,'/',paramfilename]);

            otherwise
                
                warning('ACHTUNG!!! Invalid input!!! DO IT AGAIN!!!');
        

        end
    end
end


% Generate blank folder
if exist([p(idx).rootdir,'/blank/'],'dir')
    system(['rm -rf ',p(idx).rootdir,'/blank/']);
end
system(['mkdir ',p(idx).rootdir,'/blank/']);

% Clear checkjobs folder
if exist([p(idx).rootdir,'/',p(idx).checkjobdir],'dir')
    system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,'/',p(idx).checkjobdir]);
else
    system(['mkdir ',p(idx).rootdir,'/',p(idx).rootdir]);
end

% Clear complete folder
if exist([p(idx).rootdir,'/',p(idx).completedir,'/'],'dir')
    system(['rm -rf ',p(idx).rootdir,'/',p(idx).completedir,'/*']);
else
    system(['mkdir ',p(idx).rootdir,'/',p(idx).completedir]);
end


% Check for alignment job and clear motl folder
if any(strcmp(p(idx).subtomo_mode,ali_modes))
    [splitmotldir,~,~] = fileparts(p(idx).splitmotlname);
    if exist([p(idx).rootdir,splitmotldir],'dir')
        if ~p(idx).completed_ali && ~any(strcmp(p(idx).subtomo_mode,avg_modes))
            % Clear motls folder
            system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,splitmotldir]);
        end
    else
        system(['mkdir ',p(idx).rootdir,'/',splitmotldir]);
    end
end

% Submit job
system(submit_cmd);

%% Start watching...
run = true;
while run
    disp(['Starting subtomogram averaging run for iteration ',num2str(p(idx).iteration),'...']);
    
    % Read allmotl file
    allmotlname = [p(idx).allmotlname,'_',num2str(p(idx).iteration),'.em'];
    allmotl = read_em(rootdir,allmotlname);
    n_motls = size(allmotl,2);
    
    % Determine number of classes
    switch p(idx).subtomo_mode
        case {'ali_singleref','avg_singleref'}
            n_classes = 1;
        otherwise
            classes = unique(allmotl(20,:));
            if p(idx).iclass == 0
                n_classes = numel(classes);
            else
                n_classes = numel(intersect(classes,p(idx).iclass));
            end
    end
       
    
    % Subtomogram alignment
    if ~p(idx).completed_ali && ~any(strcmp(p(idx).subtomo_mode,avg_modes))
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_ali']);    % Prevents overrun at next step...

        
        disp('Starting subtomogram alignment...');
        
        % Wait until align completion
        [mdir,~,~] = fileparts(p(idx).splitmotlname);
        motldir = [p(idx).rootdir,'/',mdir,'/'];
        n_ali_motl = 0;
        n_back = 0;
        while n_ali_motl < n_motls
            pause(10);
            [~,n_ali_motl] = system(['listdir ',motldir,' | wc -l']);
            n_ali_motl = str2double(n_ali_motl)-2;
            status = [num2str(n_ali_motl),' out of ',num2str(n_motls),' aligned...'];
            n_back = print_status(status, n_back);
            
        end
        
        % Update param file
        [p,idx] = update_param(rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'ali');
        
        % Write completion file
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_p_aver']);    % Prevents overrun at next step...
        system(['touch ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_ali']);
        fprintf(['\n','Subtomogram alignment complete!!!\n']);
        
    end
    
    
    % Parallel average
    if ~p(idx).completed_p_aver
        disp('Starting parallel averaging...');
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_p_aver']);    % Prevents overrun at next step...

        % Wait until parallel averaging completion
        checkjobdir = [p(idx).rootdir,'/',p(idx).checkjobdir,'/'];
        n_p_aver = 0;
        n_back = 0;
        while n_p_aver < p(idx).n_cores_aver
            pause(10);
            [~,n_p_aver] = system(['listdir ',checkjobdir,' | wc -l']);
            n_p_aver = str2double(n_p_aver)-2;
            status = [num2str(n_p_aver),' out of ',num2str(p(idx).n_cores_aver),' parallel averages completed...'];
            n_back = print_status(status, n_back);
        end
        
        % Update param file
        [p,idx] = update_param(rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'p_aver');
        
        % Cleanup
        if any(strcmp(p(idx).subtomo_mode,ali_modes))
            [motldir,~,~] = fileparts(p(idx).splitmotlname);
            system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,'/',motldir]);            
        end
        system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,'/',p(idx).checkjobdir]);  
        
        % Write completion file
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_f_aver']);    % Prevents overrun at next step...
        system(['touch ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_p_aver']);
        fprintf(['\n','Parallel averaging complete!!!\n']);
        
    end    
        
    % Final average
    if ~p(idx).completed_f_aver
        disp('Starting final averaging...');
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_f_aver']);    % Prevents overrun at next step...

        % Wait until final averaging completion
        checkjobdir = [p(idx).rootdir,'/',p(idx).checkjobdir,'/'];
        n_final_avg = 0;
        n_back = 0;
        while n_final_avg < n_classes
            pause(10);
            [~,n_final_avg] = system(['listdir ',checkjobdir,' | wc -l']);
            n_final_avg = str2double(n_final_avg)-2;
            status = [num2str(n_final_avg),' out of ',num2str(n_classes),' final averages completed...'];
            n_back = print_status(status, n_back);
        end
        
        % Update param file
        [p,idx] = update_param(rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'f_aver');        
        
        % Clean up for iteration
        stopgap_cleanup(p,idx);
        
        % Write completion file
        system(['rm -f ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_ali']);    % Prevents overrun at next step...
        system(['touch ',p(idx).rootdir,'/',p(idx).completedir,'/stopgap_f_aver']);
        fprintf(['\n','Final averaging complete!!!\n']);
        
    end       
        

    % Check for exit condition
    if idx > numel(p);
        run = false;        
    end
    
end

% Clear complete folder

disp('Subtomogram averaging complete!!!1!');

