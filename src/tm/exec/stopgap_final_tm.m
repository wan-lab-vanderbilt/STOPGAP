function stopgap_final_tm(p,s,o,idx)
%% stopgap_final_tm
% Complete template matching run. This involves compiling the scoring map
% and the orientation map. 
%
% WW 01-2019


%% Initialize volumes
disp([s.nn,'Finalizing template matching for tomo: ',num2str(p(idx).tomo_num),'...']);

% Intialize volumes
s_map = zeros(o.tomo_size,'single');
o_map = zeros(o.tomo_size,'int16');
if sg_check_param(p(idx),'noise_corr')
    n_map = zeros(o.tomo_size,'single');
end
if o.n_tmpl > 1
    t_map = zeros(o.tomo_size,'int16');
end



%% Fill volumes
disp([s.nn,'Compiling final maps...']);

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',o.n_cores,s.counter_pct);

% Compile final maps
for i = 1:o.n_cores
    
    % Partial volume names
    s_name = [o.tempdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),s.vol_ext];
    o_name = [o.tempdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),s.vol_ext];
    
    % Paste maps    
    s_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = read_vol(s,p(idx).rootdir,s_name);
    o_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = read_vol(s,p(idx).rootdir,o_name);

    if p(idx).noise_corr
        n_name = [o.tempdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),s.vol_ext];
        n_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = read_vol(s,p(idx).rootdir,n_name);
    end
    
    if o.n_tmpl > 1
        t_name = [o.tempdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),s.vol_ext];
        t_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = read_vol(s,p(idx).rootdir,t_name);
    end
    
    
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',o.n_cores,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(o.n_cores),' tiles summed... ',rt_str]);
    end
    
end

% Generate noise-compensated scoring map
if p(idx).noise_corr
    
    % Save raw map
    rs_map = s_map; % Raw s_map
    
    % Noise subtraction
    s_map = (s_map-n_map)./(1-n_map);
    
    % Threshold
    s_map = s_map.*(s_map > 0);
    
    
end

% Check for masked regions
if sg_check_param(p(idx),'tomo_mask_name')
    
    % Read mask
    tomo_mask = sg_mrcread(p(idx).tomo_mask_name);
    
    % Apply mask
    s_map = s_map.*single(tomo_mask);
    o_map = o_map.*int16(tomo_mask);
    
    
    if o.n_tmpl > 1
        t_map = t_map.*int16(tomo_mask);
    end
    
end
%% Write outputs and cleanup
disp([s.nn,'Writing final maps...']);

% Generate output names
s_name = [o.mapdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
o_name = [o.mapdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];


% Write output files
write_vol(s,o,p(idx).rootdir,s_name,s_map);
write_vol(s,o,p(idx).rootdir,o_name,o_map);

% Write raw files
if s.write_raw
    if p(idx).noise_corr
        n_name = [o.rawdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,n_name,n_map);        
        rs_name = [o.rawdir,'raw_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,rs_name,rs_map);
    end    
end

if o.n_tmpl > 1
    t_name = [o.mapdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
    write_vol(s,o,p(idx).rootdir,t_name,t_map);
end


disp([s.nn,'Template matching for tomo: ',num2str(p(idx).tomo_num),' complete!!!!1!!11!']);




