function stopgap_final_tm(p,s,o,idx)
%% stopgap_final_tm
% Complete template matching run. This involves compiling the scoring map
% and the orientation map. 
%
% WW: Edited in 07-2024 for matchlist parallelization.
%
% WW 07-2024

%% Initialize list of tiles

% Calculate job parameters
[~,~, job_array] = job_start_end(o.n_matches, o.n_cores);

% Compile a list of parallel outputs for each tile
tile_list = zeros(o.n_tiles*o.n_cores,2);   % Initialize more than necessary; columns: tile_idx, procnum
t = 1;  % Counter

for i = 1:o.n_cores
    % Determine how many tiles this core matched
    tiles_matched = unique(o.matchlist(job_array(i,2):job_array(i,3),1));
    n_tiles_matched = numel(tiles_matched);
    
    % Fill tile_list
    tile_list(t:(t+n_tiles_matched-1),1) = tiles_matched;
    tile_list(t:(t+n_tiles_matched-1),2) = i;
    
    % Increment counter
    t = t + n_tiles_matched;
    
end

% Total number of tiles
total_tiles = t-1;

%% Initialize volumes
disp([s.cn,'Finalizing template matching for index: ',num2str(idx),'...']);

% Intialize volumes
s_map = zeros(o.tomo_size,'single');
o_map = zeros(o.tomo_size,'int16');
if sg_check_param(p(idx),'noise_corr')
    n_map = zeros(o.tomo_size,'single');
end
if o.n_tmpl > 1
    t_map = zeros(o.tomo_size,'int16');
end



%% Compile full maps
disp([s.cn,'Compiling full maps...']);

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',total_tiles,s.counter_pct);


% Loop through and sum tiles
for i = 1:o.n_tiles
    
%     % Determine number of tiles
%     tile_idx = find(tile_list(:,1) == i);
%     n_par_tiles = numel(tile_idx);

    % Find all volumes for current tile
    s_dir = dir([o.tempdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_*',s.vol_ext]);
    o_dir = dir([o.tempdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_*',s.vol_ext]);
    if p(idx).noise_corr
        n_dir = dir([o.tempdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_*',s.vol_ext]);
    end
    if o.n_tmpl > 1
        t_dir = dir([o.tempdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_*',s.vol_ext]);
    end
    
    % Parse number of tiles
    n_par_tiles = numel(s_dir);
    
    % Sum parallel tiles
    for j = 1:n_par_tiles
        
%         % Parse procnum
%         procnum = tile_list(tile_idx(j),2);
%         
%         % Parse partial volume names
%         s_name = [o.tempdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_',num2str(procnum),s.vol_ext];
%         o_name = [o.tempdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_',num2str(procnum),s.vol_ext];
%         if p(idx).noise_corr
%             n_name = [o.tempdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_',num2str(procnum),s.vol_ext];
%         end
%         if o.n_tmpl >1
%             t_name = [o.tempdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),'_',num2str(i),'_',num2str(procnum),s.vol_ext];
%         end
        
        % Parse partial volume names
        s_name = [o.tempdir,s_dir(j).name];
        o_name = [o.tempdir,o_dir(j).name];
        if p(idx).noise_corr
            n_name = [o.tempdir,n_dir(j).name];
        end
        if o.n_tmpl > 1
            t_name = [o.tempdir,t_dir(j).name];
        end
        
        
        % Read maps
        if j == 1
            
            % Read first partial tiles
            temp_s_map = read_vol(s,p(idx).rootdir,s_name);
            temp_o_map = read_vol(s,p(idx).rootdir,o_name);
            
            % Read partial noise map
            if p(idx).noise_corr
                temp_n_map = read_vol(s,p(idx).rootdir,n_name);
            end
            
            % Read partial template map
            if o.n_tmpl > 1
                temp_t_map = read_vol(s,p(idx).rootdir,t_name);
            end
            
        else
            
            
            % Read next score map tiles
            temp_map2 = read_vol(s,p(idx).rootdir,s_name);
            
            % Determine highest scores
            top_idx = temp_map2 > temp_s_map;
            
            % Store scores
            temp_s_map(top_idx) = temp_map2(top_idx);
            
            
            
            % Read and store next orientation map
            temp_map2 = read_vol(s,p(idx).rootdir,o_name);
            temp_o_map(top_idx) = temp_map2(top_idx);
            
                        
            % Read and store next noise map
            if p(idx).noise_corr
                temp_map2 = read_vol(s,p(idx).rootdir,n_name);
                temp_n_map(top_idx) = temp_map2(top_idx);
            end
            
            % Read partial template map
            if o.n_tmpl > 1
                temp_map2 = read_vol(s,p(idx).rootdir,t_name);
                temp_t_map(top_idx) = temp_map2(top_idx);
            end
            
            
        end
        
        
        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',total_tiles,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.cn,'Job progress: ',num2str(pc.c),' out of ',num2str(total_tiles),' tiles summed... ',rt_str]);
        end
        
    end     % Procnum loop
    if n_par_tiles > 1
        clear top_idx
    end
    
    
    
    % Paste maps    
    s_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = temp_s_map;
    o_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = temp_o_map;
    if p(idx).noise_corr
        n_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = temp_n_map;
        clear temp_n_map
    end    
    if o.n_tmpl > 1
        t_map(o.c.bs(i,1):o.c.be(i,1),o.c.bs(i,2):o.c.be(i,2),o.c.bs(i,3):o.c.be(i,3)) = temp_t_map;
        clear temp_t_map
    end
    
    
    clear temp_s_map temp_o_map
    
end         % Tile loop


    
%% Postprocess maps    

% Generate noise-compensated scoring map
if p(idx).noise_corr
    
    % Save raw map
    if s.write_raw
        rs_map = s_map; % Raw s_map
    end
    
    % Noise subtraction
    s_map = (s_map-n_map)./(1-n_map);
    
    % Threshold
    s_map = s_map.*(s_map > 0);
    
end



% Check for masked regions
if sg_check_param(p(idx),'tomo_mask_name')
    
    % Read mask
    tomo_mask = sg_volume_read(p(idx).tomo_mask_name);
    
    % Apply mask
    s_map = s_map.*single(tomo_mask);
    o_map = o_map.*int16(tomo_mask);
    
    % Apply to template map
    if o.n_tmpl > 1
        t_map = t_map.*int16(tomo_mask);
    end
    
end


%% Write outputs and cleanup
disp([s.cn,'Writing final maps...']);

% Generate output names
s_name = [o.mapdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
o_name = [o.mapdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];


% Write output files
write_vol(s,o,p(idx).rootdir,s_name,s_map);
disp([s.cn,p(idx).rootdir,s_name,' written!']);
write_vol(s,o,p(idx).rootdir,o_name,o_map);
disp([s.cn,p(idx).rootdir,o_name,' written!']);

% Write raw files
if s.write_raw
    if p(idx).noise_corr
        n_name = [o.rawdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,n_name,n_map);   
        disp([s.cn,p(idx).rootdir,n_name,' written!']);
        rs_name = [o.rawdir,'raw_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
        write_vol(s,o,p(idx).rootdir,rs_name,rs_map);
        disp([s.cn,p(idx).rootdir,rs_name,' written!']);
    end    
end

if o.n_tmpl > 1
    t_name = [o.mapdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),s.vol_ext];
    write_vol(s,o,p(idx).rootdir,t_name,t_map);
    disp([s.cn,p(idx).rootdir,t_name,' written!']);
end


disp([s.cn,'Template matching for index ',num2str(idx),' complete!!!!1!!11!']);




