function stopgap_parallel_tm(p,o,s,idx)
%% stopgap_parallel_tm
% Perform parallel template matching on the tomogram defined in the
% parameter file for the given index.
%
% Each core processes a tile of the tomogram; each core calculates
% correlations between all search orientations and templates. 
%
% WW: Updated to parallelize over the "match_list". 
%
% WW 07-2024


%% Initialize 

% Initialize volume struct
v = struct();

% Initialize tile index
v.tile_idx = -1;


% Calculate job parameters
[~,~, job_array] = job_start_end(o.n_matches, o.n_cores);

% Open progress file
prog = fopen([p(idx).rootdir,o.commdir,'ptmprog_',num2str(o.procnum)],'w');

%% Calculate packets

% Number of packets
n_packets = o.n_cores*s.packets_per_core;

% Split matches into packets
[~,~, packet_array] = job_start_end(o.n_matches, n_packets);

% Determine cores for each packet
core_packet_idx = reshape(repmat(1:o.n_cores,s.packets_per_core,1),[],1);

% Assign packets to core
packet_idx = find(core_packet_idx==o.procnum);
disp([s.cn,num2str(numel(packet_idx)),' initial packets assigned']);

%% Perform template matching
disp([s.cn,'Performing parallel template matching on tomogram ',num2str(p(idx).tomo_num),'...']);


% Initialize counter struct
pc = struct();

% For tracking packet progress
start_tm = true;            % Track when TM is started
p_idx = 1;                  % Start aligning assigned packes
comp_init_packet = false;   % Track completion of initial assigned packets

% While loop for packets
while p_idx <= numel(packet_idx)
    
    % Initialize counter for current packet
    pc = progress_counter(pc,'init',job_array(o.procnum,1),s.counter_pct);
    
    % Parse current packet number
    packet = packet_idx(p_idx); 
    
    % Check if packet has been started
    start_name = [p(idx).rootdir,o.commdir,'tmpacket_',num2str(packet)];
    [packet_check,~] = system(['mkdir ',start_name]);
    if packet_check ~= 0
        p_idx = p_idx + 1;
        continue
    end  
    disp([s.cn,'Matching packet ',num2str(packet),' out of ',num2str(o.n_packets),'!!!']); 

    
    
    % Loop through current packet
    for i = packet_array(packet,2):packet_array(packet,3)

        % Parse current tile index
        tile_idx = o.matchlist(i,1);

        %%%%% Check to refresh volumes %%%%%
        if v.tile_idx ~= tile_idx
            
            %%%%% Write Previous Volumes %%%%%
            if ~start_tm
                disp([s.cn,'New tile assigned for template matching. Writing results from previous tile...']);
                write_parallel_tm_volumes(p,o,s,idx,v);
            end
            
            
            %%%%% Refresh Volumes %%%%%
            disp([s.cn,'Refreshing volumes for template matching on tile ',num2str(tile_idx),'...']);

            % Read in tile
            
            disp([s.cn,'Reading tile...']);
            v.tile = read_tm_tiles(p,o,idx,'tomo',tile_idx);

            % Determine cropped size
            c_size = o.c.ce(tile_idx,:) - o.c.cs(tile_idx,:) + 1;

            % Initialize output maps
            v.s_map = ones(c_size,'single')*-2;        % Initialize output CC maps
            v.o_map = zeros(c_size,'int16');        % Initialize output orientation maps

            % Initialize output template ID maps
            if o.n_tmpl > 1
                v.t_map = zeros(c_size,'int16');        
            end

            % Initialize noise map
            if o.noise_corr
                v.n_map = ones(c_size,'single')*-2;        % Initialize output CC maps
            end



            % Initialize filter array
            disp([s.cn,'Generating filters...']);
            f = generate_tm_filters(p,o,s,idx);

            % Prepare tiles
            disp([s.cn,'Preparing tiles...']);
            v = prepare_tiles_tm(p,idx,o,f,v);

            % Update tile index
            v.tile_idx = tile_idx;

            disp([s.cn,'Tile prepared... Starting template matching!!!']);
        end


        %%%%% Prepare template %%%%%

        % Parse template and angle index
        tmpl_idx = o.matchlist(i,2);
        ang_idx = o.matchlist(i,3);


        % Parse angle
        euler = o.ang{tmpl_idx}(:,ang_idx)';

        % Rotate volumes
        rot_tmpl = sg_rotate_vol(o.tmpl{tmpl_idx},euler,[],'linear');
        rot_mask = sg_rotate_vol(o.mask{tmpl_idx},euler,[],'linear');
        rot_mask(rot_mask < exp(-2)) = 0;   % Cutoff values            


        % Filter rotated template
        rot_tmpl = real(ifftn(fftn(rot_tmpl).*f.tmpl_filt));


        % Pad rotated volumes
        rTmpl =  sg_pad_volume(rot_tmpl,o.tilesize);
        rMask =  sg_pad_volume(rot_mask,o.tilesize);


        % Normalize under mask
        rTmpl = normalize_under_mask(rTmpl,rMask);  


        % Calculate autocorrelation function
        if any(strcmp(s.scoring_fcn,'scf'))
            acf = sg_autocorrelation(rTmpl,rMask);
            acf = normalize_under_mask(acf,rMask);
        end



        %%%%% Score match %%%%%

        % Calculate CC
        score_map = calculate_flcf(rTmpl,rMask,v.conjTile,v.conjTile2);
        clear rTmpl

        % Calculate SCF
        if any(strcmp(s.scoring_fcn,'scf'))
            conjScore = conj(fftn(score_map));
            conjScore2 = conj(fftn(score_map.^2));
            score_map = calculate_flcf(acf,rMask,conjScore,conjScore2);
        end

        % Un-Fourier crop volume
        if o.fcrop
            score_map = fourier_uncrop_volume(score_map,o.f_idx_tile,o.tile_bpf);            
        end

        % Crop score map
        crop_map = score_map(o.c.cs(tile_idx,1):o.c.ce(tile_idx,1),...
                             o.c.cs(tile_idx,2):o.c.ce(tile_idx,2),...
                             o.c.cs(tile_idx,3):o.c.ce(tile_idx,3));
        clear score_map



        %%%%% Find optimal match %%%%%

        % Match
        top_idx = crop_map > v.s_map;          % Find voxels with best scores
        v.s_map(top_idx) = crop_map(top_idx);  % Replace top-scoring voxels
        v.o_map(top_idx) = ang_idx;                  % Store angle list index   

        % Store template index
        if i > 1
            v.t_map(top_idx) = i;    
        end
        clear crop_map top_idx



        % Calculate noise correlation
        if o.noise_corr
            for j = 1:o.noise_corr

                % Rotate and filter
                rraTmpl = sg_rotate_vol(o.pr_tmpl{tmpl_idx}{j},euler,[],'linear');
                rraTmpl = real(ifftn(fftn(rraTmpl).*f.tmpl_filt));
                raTmpl = sg_pad_volume(rraTmpl,o.tilesize);

                % Normalize under mask
                raTmpl = normalize_under_mask(raTmpl,rMask);  

                % Calculate CC
                noise_map = calculate_flcf(raTmpl,rMask,v.conjTile,v.conjTile2);
                clear rMask

                % Un-Fourier crop volume
                if o.fcrop
                    noise_map = fourier_uncrop_volume(noise_map,o.f_idx_tile,o.tile_bpf);
                end

                % Crop score map
                crop_noise_map = noise_map(o.c.cs(tile_idx,1):o.c.ce(tile_idx,1),...
                                           o.c.cs(tile_idx,2):o.c.ce(tile_idx,2),...
                                           o.c.cs(tile_idx,3):o.c.ce(tile_idx,3));
                clear noise_map

                % Match
                top_idx = crop_noise_map > v.n_map;
                v.n_map(top_idx) = crop_noise_map(top_idx);
                clear crop_noise_map top_idx
            end

        end



        %%%%% Write volumes %%%%%       %% WW: Maybe move to start. If tile
        %%%%% is refreshed, write output then refresh. Then you need to
        %%%%% also add a write outside the loop, since loop is <= total.

%         % Check if volumes need to be written
%         write_vols = false;
%         if i == job_array(o.procnum,3) 
%             % End of loop
%             write_vols = true;
%         elseif v.tile_idx ~= o.matchlist(i+1,1)
%             % Upcoming tile refresh
%             write_vols = true;
%         end
% 
%         % Write volumes
%         if write_vols
%             write_parallel_tm_volumes(p,o,s,idx,v);
%         end




        %%%%% Track job progress %%%%%        

        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',packet_array(packet,1),s.counter_pct);
        if ~isempty(rt_str)
            disp([s.cn,'Job progress: ',num2str(pc.c),' out of ',num2str(packet_array(packet,1)),' angles matched... ',rt_str]);
        end                   

        % Write job progress
        fprintf(prog,'%i\n',i);            
        
    end         % End matchlist loop
    
    
    
    %%%%% Prepare for next packet %%%%%
    
    % Check for first alignment
    if start_tm
        start_tm = false;
    end
                
    % Increment counter
    p_idx = p_idx + 1;

%     %%%%% DEBUG %%%%%
%     if (p_idx > numel(packet_idx))
%         break
%     end
    
    
    % Find remaining packets after initial completion
    if (p_idx > numel(packet_idx)) && ~comp_init_packet
        % Mark initial packets complete
        comp_init_packet = true;

        % Parse packet starting directories
        packet_dir = dir('comm/tmpacket_*');


        % Parse packet numbers
        comp_packet = zeros(1,numel(packet_dir));
        for d = 1:numel(packet_dir)
            comp_packet(d) = str2double(packet_dir(d).name(find(packet_dir(d).name=='_',1,'last')+1:end));
        end

        % Generate new packet index
        packet_idx = setdiff(1:n_packets,comp_packet);

        % Flip order, so catchup calculations go from bottom up
        packet_idx = fliplr(packet_idx);

        % Determine current tile
        curr_tile = o.matchlist(i,1);

        % Find first packet with current tile
        first_packet_idx = find(o.matchlist(packet_array(packet_idx,2),1)==curr_tile,1);

        % If packets are found
        if ~isempty(first_packet_idx)
            % Shift the array to place current tile on top
            packet_idx = circshift(packet_idx,-first_packet_idx+1)';
        end


    end
        

end             % End while loop
fclose(prog);


% Write volumes
write_parallel_tm_volumes(p,o,s,idx,v);


% Write local checkjob
if o.copy_local
    system(['touch ',o.rootdir,'copy_comm/sg_ptm_',o.tomo_num,'_',num2str(o.local_id)]);
end

% Write checkjob
system(['touch ',p(idx).rootdir,o.commdir,'sg_ptm_',o.tomo_num,'_',num2str(o.procnum)]);
disp([s.cn,'Parallel template matching complete!!!']);  



end

%% Write outputs
function write_parallel_tm_volumes(p,o,s,idx,v)

disp([s.cn,'Writing parallel template matching output for tile ',num2str(v.tile_idx),' on core ',num2str(o.procnum),'...']);
    
% Generate names
s_name = [s.tempdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(v.tile_idx),'_',num2str(o.procnum),s.vol_ext];
o_name = [s.tempdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),'_',num2str(v.tile_idx),'_',num2str(o.procnum),s.vol_ext];    

% Write output
write_vol(s,o,o.rootdir,s_name,v.s_map);
disp([s.cn,o.rootdir,s_name,' written...']);
write_vol(s,o,o.rootdir,o_name,v.o_map);
disp([s.cn,o.rootdir,o_name,' written...']);


% Write noise map
if o.noise_corr
    n_name = [s.tempdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(v.tile_idx),'_',num2str(o.procnum),s.vol_ext];
    write_vol(s,o,o.rootdir,n_name,v.n_map);    
%     write_vol(s,o,p(idx).rootdir,n_name,v.n_map);
    disp([s.cn,o.rootdir,n_name,' written...']);
end

if o.n_tmpl > 1
    t_name = [s.tempdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),'_',num2str(v.tile_idx),'_',num2str(o.procnum),s.vol_ext];
    write_vol(s,o,o.rootdir,t_name,v.t_map);
%     write_vol(s,o,p(idx).rootdir,t_name,v.t_map);
    disp([s.cn,o.rootdir,t_name,' written...']);
end     


end






