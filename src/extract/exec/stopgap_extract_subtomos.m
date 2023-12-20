function stopgap_extract_subtomos(s)
%% stopgap_extract_subtomos
% A STOPGAP function to extract subtomograms.
%
% WW 04-2021

%% Initialize
disp([s.cn,'Initializing...']);


% Read parameter file
disp([s.cn,'Reading parameter file...']);
[p,idx] = update_extract_param(s,s.rootdir, s.paramfilename);
if isempty(idx)
    error([s.cn,'ACHTUNG!!! All jobs in param file are finished!!!']);
end

% Read settings
disp([s.cn,'Reading settings...']);
s = sg_get_extract_settings(s,p(idx).rootdir,'extract_settings.txt');


% Initialize struct array
o = initialize_o_struct(p,s,idx,'extract');

% o = initialize_o_struct(s);
% o = sg_parse_extract_directories(p,o,s,idx);



% % Cleanup comm folder
% if o.procnum == 1
%     system(['rm -f ',p(end).rootdir,'/',o.commdir,'/*']);
% end

%% Begin big loop
run = true;
while run        
    
    % Initialize
    o.rootdir = p(idx).rootdir;                     % Set rootdir
    o = extract_initialize_motivelist(p,o,s,idx);   % Initialize motivelist
    o = extract_read_wedgelist(p,o,s,idx);          % Read wedgelist if provided
    o = extract_check_local_extraction(p,o,s,idx);        % Check for local extraction
    
    % Tomogram loop
    if o.procnum <= o.n_tomos
        for i = o.procnum:o.n_tomos

            % Check for start
            start_name = [p(idx).rootdir,'/',o.commdir,'/exstart_',num2str(idx),'_',num2str(o.tomolist.tomo_num(i))];
            if ~exist(start_name,'file')
                system(['touch ',start_name]);
                disp([s.cn,'Reading tomogram ',num2str(o.tomolist.tomo_num(i)),'!!!']);        
            else
                continue
            end

            % Initialize tomogram parameters        
            o.tomo_num = o.tomolist.tomo_num(i);                % Parse tomogram number
            o = extract_get_tomo_header(o,s,i);                 % Read header
            o = extract_check_pixelsize(p,o,s,idx,i);           % Set pixelsizes
            o = extract_check_rescaling(p,o,s,idx);             % Check for rescaling
            o = extract_parse_subtomo_positions(p,o,s,idx);     % Parse subtomogram extraction positionss

            % Extract subtomograms
            extract_subtomos(p,o,s,idx,i);

            % Write completion
            done_name = [p(idx).rootdir,'/',o.commdir,'/exdone_',num2str(idx),'_',num2str(o.tomo_num)];
            fid = fopen(done_name,'w');
            fprintf(fid,'%s \n',num2str(o.tomo_num));
            fclose(fid);



        end
    end
        
    
    % Wait for all jobs to complete
    wait_for_them([p(idx).rootdir,'/',o.commdir],['exdone_',num2str(idx)],o.n_tomos,s.wait_time);

    % Copy from local to remote
    if o.copy_local
        extract_copy_subtomograms(p,o,s,idx);
    end
    
    % Complete iteration
    if o.procnum ~= 1
        disp([s.cn,'Subtomogram extraction complete for task ',num2str(idx),' waiting for iteration to finish...']);
        
        % Wait for job completion
        wait_for_it([p(idx).rootdir,'/',o.commdir],['complete_extraction_',num2str(idx)],s.wait_time);
        
        % Update param file
%         old_idx = idx;
        [p,idx] = update_extract_param(s,s.rootdir, s.paramfilename);
   
    else
        disp([s.cn,'Subtomogram extraction complete for task ',num2str(idx),' waiting for other nodes to finish...']);
        
        % Update param file
        old_idx = idx;
        [p,idx] = update_extract_param(s,s.rootdir, s.paramfilename,old_idx);

        % Write checkjob
        system(['touch ',p(old_idx).rootdir,'/',o.commdir,'complete_extraction_',num2str(old_idx)]);
        
    end
    
    
    
        
    
    
    % Check for completion
    if isempty(idx)
        run = false;
    end
    
end

disp([s.cn,'All jobs complete!!!']);




