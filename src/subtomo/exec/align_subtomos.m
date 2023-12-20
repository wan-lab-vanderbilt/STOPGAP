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
sm = write_splitmotl(p,o,idx,sm,'init',[],[]);


%% Perform angular search
disp([s.cn,'Beginning subtomogram alignment!!!'])


% Track computation time: procnum, node_id, local_id, 
time_array = zeros(o.n_ali_motls,10);
t = 1;  % time_array index counter

% Parse packet parameters
% if o.copy_local == 1
%     start_id = o.local_id;
% else
%     start_id = o.procnum;
% end

% Parse packets
% if o.copy_local
%     packet_idx = ((0:(s.packets_per_core-1)).*o.cores_on_node)+o.local_id;
% else
%     packet_idx = ((0:(s.packets_per_core-1)).*o.n_cores)+o.procnum;
% end
if o.copy_local
    [p_start, p_end] = job_start_end(o.total_packets, o.cores_on_node,o.local_id);
else
    [p_start, p_end] = job_start_end(o.total_packets, o.n_cores,o.procnum);
end
packet_idx = p_start:p_end;


% For tracking progres
p_idx = 1;                  % Start aligning assigned packes
comp_init_packet = false;   % Track completion of initial assigned packets

% Continuous alignment until completion
while p_idx <= numel(packet_idx)
    % Parse packet index
    packet = packet_idx(p_idx);
    
    % Initialize packet timer
    packet_timer = tic;
    
    % Check if packet has been started
    if o.copy_local == 1
        start_name = [o.rootdir,o.commdir,'alipacket_',num2str(packet)];
    else
        start_name = [p(idx).rootdir,o.commdir,'alipacket_',num2str(packet)];
    end
    [packet_check,~] = system(['mkdir ',start_name]);
    if packet_check ~= 0
        p_idx = p_idx + 1;
        continue
    end  
    disp([s.cn,'Aligning packet ',num2str(packet),' out of ',num2str(o.total_packets),'!!!']); 
    
    
    % Loop over batch    
    for i = o.packet_array(packet,2):o.packet_array(packet,3)
        subtomo_timer = tic;

        % Parse out motls for a single motivelist entry
        motl_idx = o.allmotl.motl_idx == o.ali_motl(i);
        motl = parse_motl(o.allmotl,motl_idx);                


        % Read in subtomogram
        tic;
        name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(motl.subtomo_num(1)),s.vol_ext];
        v.subtomo = read_vol(s,o.rootdir,name);     
        subtomo_read_time = toc;

        % Calculate laplacian
        if sg_check_param(p(idx),'apply_laplacian')
            v.subtomo = del2(v.subtomo);
        end

        % Check filters
        tic;
        f = refresh_subtomo_filters(p,o,s,f,idx,motl,'ali');
        filter_refresh_time = toc;

        % Prepare subtomogram
        [o,v] = score_subtomo_alignment(p,o,s,idx,v,'prep',f,[]);


        % Initialize alignment array
        ali = initialize_align_struct(p,o,idx,motl);

        % Score alignment
        tic;
        [o,v,ali] = score_subtomo_alignment(p,o,s,idx,v,'score',f,ali);   
        ali_time = toc;

        % Fill split motl
    %     splitmotl = fill_splitmotl(splitmotl,ali,m);
    %     m = m+1;    % Split motl index
        tic;
        sm = write_splitmotl(p,o,idx,sm,'write',motl,ali);
        motl_write_time = toc;

        % Write progress
        fprintf(status,'%s \n',num2str(o.ali_motl(i)));
        
        % Fill timer array
        subtomo_time = toc(subtomo_timer);
        time_array(t,1) = o.procnum;
        time_array(t,2) = o.node_id;
        time_array(t,3) = o.local_id;
        time_array(t,4) = packet;
        time_array(t,5) = o.ali_motl(i);
        time_array(t,6) = subtomo_read_time;
        time_array(t,7) = filter_refresh_time;
        time_array(t,8) = ali_time;
        time_array(t,9) = motl_write_time;
        time_array(t,10) = subtomo_time;
        % Increment counter
        t = t+1;
        
    end % End alignment loop
    
    
    % Write timing output    
    packet_time = toc(packet_timer);
    if o.copy_local == 1
        disp([s.cn,' Node ',num2str(o.node_id),' Packet ',num2str(packet),' aligned in ',num2str(packet_time)]);
    else
        disp([s.cn,'Packet ',num2str(packet),' aligned in ',num2str(packet_time)]);
    end
    
    % Increment counter
    p_idx = p_idx + 1;
    
    % Find remaining packets after initial completion
    if (p_idx > numel(packet_idx)) && ~comp_init_packet
        % Mark initial packets complete
        comp_init_packet = true;

        % Parse packet starting directories
        if o.copy_local == 1
            packet_dir = dir([o.rootdir,'/',o.commdir,'/alipacket_*']);
        else
            packet_dir = dir([p(idx).rootdir,'/',o.commdir,'/alipacket_*']);
        end
        
        % Parse packet numbers
        comp_packet = zeros(1,numel(packet_dir));
        for d = 1:numel(packet_dir)
            comp_packet(d) = str2double(packet_dir(d).name(find(packet_dir(d).name=='_',1,'last')+1:end));
        end
        
        % Generate new packet index
        packet_idx = setdiff(1:o.total_packets,comp_packet);
        packet_idx = packet_idx(randperm(numel(packet_idx)));   % Randomize order of packets
        
        % Reset packet counter
        p_idx = 1;
    end
end     % End packet loop

%% Write outputs

% Close status writer
sm = write_splitmotl(p,o,idx,sm,'close',[]);
fclose(status);

% Write timings
time_array = time_array(1:t-1,:);
csvwrite([p(idx).rootdir,o.tempdir,'ali_timings_',num2str(p(idx).iteration+1),'_',num2str(o.procnum),'.csv'],time_array);


% % Write partial motl
% splitmotl_name = [p(idx).rootdir,'/',o.tempdir,'/splitmotl_',num2str(o.procnum),'.star'];
% sg_motl_write2(splitmotl_name,splitmotl,true);

% Write completion file
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_ali_',num2str(o.procnum)]);


disp([s.cn,'Subtomogram alignment in iteration ',num2str(p(idx).iteration),' completed!!!1!one!']);

end

