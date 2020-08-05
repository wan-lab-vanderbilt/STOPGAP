function stopgap_parallel_tm(p,o,s,idx)
%% stopgap_parallel_tm
% Perform parallel template matching on the tomogram defined in the
% parameter file for the given index.
%
% Each core processes a tile of the tomogram; each core calculates
% correlations between all search orientations and templates. 
%
% WW 04-2019

%% Initialize volumes and filters
disp([s.nn,'Initializing volumes for template matching...']);


% Initialize volume struct
v = struct();

% Read in tile
disp([s.nn,'Reading tile...']);
v.tile = read_tm_tiles(p,o,idx,'tomo');

% Determine cropped size
c_size = o.c.ce(o.procnum,:) - o.c.cs(o.procnum,:) + 1;

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
disp([s.nn,'Generating filters...']);
f = generate_tm_filters(p,o,s,idx);

% Open progress file
prog = fopen([p(idx).rootdir,o.commdir,'ptmprog_',num2str(o.procnum)],'w');


% Prepare tiles
disp([s.nn,'Preparing tiles...']);
v = prepare_tiles_tm(p,idx,o,f,v);



%% Perform template matching
disp([s.nn,'Performing parallel template matching on tomogram ',num2str(p(idx).tomo_num),'...']);
tot_ang = sum(o.n_ang);

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',tot_ang,s.counter_pct);

% Loop through templates
for i = 1:o.n_tmpl            

    % Loop through angles for each template
    for j = 1:o.n_ang(i)
            
        %%%%% Prepare template %%%%%
        
        % Parse angle
        euler = o.ang{i}(:,j)';

        % Rotate volumes
        rot_tmpl = sg_rotate_vol(o.tmpl{i},euler,[],'linear');
        rot_mask = sg_rotate_vol(o.mask{i},euler,[],'linear');
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
        crop_map = score_map(o.c.cs(o.procnum,1):o.c.ce(o.procnum,1),...
                             o.c.cs(o.procnum,2):o.c.ce(o.procnum,2),...
                             o.c.cs(o.procnum,3):o.c.ce(o.procnum,3));
        clear score_map
        
        
        
        %%%%% Find optimal match %%%%%
        
        % Match
        top_idx = crop_map > v.s_map;          % Find voxels with best scores
        v.s_map(top_idx) = crop_map(top_idx);  % Replace top-scoring voxels
        v.o_map(top_idx) = j;                  % Store angle list index   
        
        % Store template index
        if i > 1
            v.t_map(top_idx) = i;    
        end
        clear crop_map top_idx
        
        
        
        % Calculate noise correlation
        if o.noise_corr
            for k = 1:o.noise_corr

                % Rotate and filter
                rraTmpl = sg_rotate_vol(o.pr_tmpl{i}{k},euler,[],'linear');
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
                crop_noise_map = noise_map(o.c.cs(o.procnum,1):o.c.ce(o.procnum,1),...
                                           o.c.cs(o.procnum,2):o.c.ce(o.procnum,2),...
                                           o.c.cs(o.procnum,3):o.c.ce(o.procnum,3));
                clear noise_map

                % Match
                top_idx = crop_noise_map > v.n_map;
                v.n_map(top_idx) = crop_noise_map(top_idx);
                clear crop_noise_map top_idx
            end
            
        end
        
        

        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',tot_ang,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(tot_ang),' angles matched... ',rt_str]);
        end                   

        % Write job progress
        fprintf(prog,'%i\n',pc.c);        
        
    end     % End angle loop
end         % End template loop

fclose(prog);




%% Write outputs
disp([s.nn,'Matching complete!!! Writing outputs...']);
    
% Generate names
s_name = [s.tempdir,p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(o.procnum),s.vol_ext];
o_name = [s.tempdir,p(idx).omap_name,'_',num2str(p(idx).tomo_num),'_',num2str(o.procnum),s.vol_ext];    

% Write output
write_vol(s,o,p(idx).rootdir,s_name,v.s_map);
write_vol(s,o,p(idx).rootdir,o_name,v.o_map);

% Write noise map
if o.noise_corr
    n_name = [s.tempdir,'noise_',p(idx).smap_name,'_',num2str(p(idx).tomo_num),'_',num2str(o.procnum),s.vol_ext];
    write_vol(s,o,p(idx).rootdir,n_name,v.n_map);    
end

if o.n_tmpl > 1
    t_name = [s.tempdir,p(idx).tmap_name,'_',num2str(p(idx).tomo_num),'_',num2str(o.procnum),s.vol_ext];
    write_vol(s,o,p(idx).rootdir,t_name,v.t_map);
end

    


% Write checkjob
system(['touch ',p(idx).rootdir,o.commdir,'sg_ptm_',o.tomo_num,'_',num2str(o.procnum)]);
    









