function align_subtomos(p,o,s,idx)
%% align_subtomos
% Perform subtomogram alignment
%
% WW 06-2019


%% Initialize

% % Parse modes
% mode = strsplit(p(idx).subtomo_mode,'_');

% Initialize filter array
f = initialize_subtomo_filters(p,o,s,idx,'ali');

% Check rotation mode
if sg_check_param(p(idx),'rot_mode')
    o.rot_mode = p(idx).rot_mode;
else
    o.rot_mode = 'linear';
end

% Volume array
v = struct();

% Initialize scoring function
[o,v] = score_subtomo_alignment(p,o,s,idx,v,'init',f,[]);

% Initialize alignment status writing
status = fopen([p(idx).rootdir,o.commdir,'aliprog_',num2str(o.procnum)],'w');

% Initialize partial motl
sm = struct();
sm = write_splitmotl(p,o,idx,sm,'init',[]);


%% Perform angular search
disp([s.nn,'Beginning subtomogram alignment!!!'])


% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',o.n_ali_motls,s.counter_pct);

% Loop over batch
for i = o.ali_motl

    % Parse out motls for a single motivelist entry
    motl_idx = o.allmotl.motl_idx == i;
    motl = parse_motl(o.allmotl,motl_idx);


    % Read in subtomogram
    name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(motl.subtomo_num(1)),s.vol_ext];
    v.subtomo = read_vol(s,p(idx).rootdir,name);     
    
    % Calculate laplacian
    if sg_check_param(p(idx),'apply_laplacian')
        v.subtomo = del2(v.subtomo);
    end
    
    % Check filters
    f = refresh_subtomo_filters(p,o,s,f,idx,motl,'ali');
        
    % Prepare subtomogram
    [o,v] = score_subtomo_alignment(p,o,s,idx,v,'prep',f,[]);
    
    
    % Initialize alignment array
    ali = initialize_align_struct(p,o,idx,motl);
    
    % Score alignment
    [o,v,ali] = score_subtomo_alignment(p,o,s,idx,v,'score',f,ali);   
    
    % Fill split motl
%     splitmotl = fill_splitmotl(splitmotl,ali,m);
%     m = m+1;    % Split motl index
    sm = write_splitmotl(p,o,idx,sm,'write',ali);
    
    % Write progress
    fprintf(status,'%s \n',num2str(i));
    
        

    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',o.n_ali_motls,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(o.n_ali_motls),' aligned... ',rt_str]);
    end


end % End alignment loop


%% Write outputs

% Close status writer
sm = write_splitmotl(p,o,idx,sm,'close',ali);
fclose(status);

% % Write partial motl
% splitmotl_name = [p(idx).rootdir,'/',o.tempdir,'/splitmotl_',num2str(o.procnum),'.star'];
% sg_motl_write2(splitmotl_name,splitmotl,true);

% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_ali_',num2str(o.procnum)]);


disp([s.nn,'Subtomogram alignment in iteration ',num2str(p(idx).iteration),' completed!!!1!one!']);

end

