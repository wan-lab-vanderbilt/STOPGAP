function extract_subtomos(p,o,s,idx,tomo_idx)
%% 
% Extract subtomograms and save to disk.
%
% WW 04-2021


%% Initialize
disp([s.cn,'Preparing for subtomogram extraction...']);

% Initialize stats array
stats = zeros(o.n_extract,3);
stats(:,1) = [o.subtomo_num];

% Expected subtomosize (bytes)
n_pix = (p(idx).boxsize^3);
switch p(idx).output_format
    case 'em'
        subtomo_size = 512 + (n_pix*4);   % Header + 32bits per voxel
        fmt = 'em';
    case 'mrc'
        subtomo_size = 1024 + (n_pix*4);  % Header + 32bits per voxel
        fmt = 'mrc';
    case 'mrc16'
        subtomo_size = 1024 + (n_pix*2);  % Header + 16bits per voxel
        fmt = 'mrc';
    case 'mrc8'
        subtomo_size = 1024 + n_pix;      % Header + 8bits per voxel
        fmt = 'mrc';
end

% Check read mode
read_full = true;
if sg_check_param(p(idx),'read_mode')
    if strcmp(p(idx).read_mode,'partial')
        disp([s.cn,'Read mode set for partial reading...']);
        read_full = false;
    end
end

% Read tomogram
if read_full
    disp([s.cn,'Reading tomogram ',o.tomolist.tomo_name{tomo_idx},'...']);
    tomogram = sg_mrcread(o.tomolist.tomo_name{tomo_idx});
    disp([s.cn,'Tomogram read!!!']);
end


%% Extract subtomos
disp([s.cn,'Starting subtomogram extraction on tomogram ',num2str(o.tomo_num),'!!!']);


% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',o.n_extract,s.counter_pct);

for i  = 1:o.n_extract
    
    % Initialize subtomogram
    subtomo = zeros(p(idx).boxsize,p(idx).boxsize,p(idx).boxsize);
    
    % Extract subtomo
    if read_full
        ext_subtomo = tomogram(o.coords.es(1,i):o.coords.ee(1,i),o.coords.es(2,i):o.coords.ee(2,i),o.coords.es(3,i):o.coords.ee(3,i));
        ext_subtomo = double(ext_subtomo);
    else
        ext_subtomo = sg_read_mrc_subvolume(mrc_name,[o.coords.es(1,i),o.coords.es(2,i),o.coords.es(3,i)],[o.coords.ee(1,i),ocoords.ee(2,i),o.coords.ee(3,i)]);
    end
    
    % Normalize
    m = mean(ext_subtomo(:));
    stdev = std(ext_subtomo(:));
    ext_subtomo = (ext_subtomo-m)./stdev;
    
    % Paste in box
    subtomo(o.coords.ss(1,i):o.coords.se(1,i),o.coords.ss(2,i):o.coords.se(2,i),o.coords.ss(3,i):o.coords.se(3,i)) = ext_subtomo;
    
    % Rescale subtomo
    if o.rescale
    end
    
    % Format conversion
    switch p(idx).output_format
        case {'em','mrc'}
            subtomo = single(subtomo);
        case 'mrc16'
            subtomo = sg_rescale_to_16bit(subtomo);
        case 'mrc8'
            subtomo = sg_rescale_to_8bit(subtomo);
    end
    
    % Recalculate stats
    stats(i,2) = mean(subtomo(:));
    stats(i,3) = std(single(subtomo(:)));
    
    % Write subtomo
    switch fmt
        case 'em'
            name = [o.rootdir,o.subtomodir,p(idx).subtomo_name,'_',s.subtomo_num(o.subtomo_num(i)),'.em'];
            sg_emwrite(name,subtomo);
        case 'mrc'
            name = [o.rootdir,o.subtomodir,p(idx).subtomo_name,'_',s.subtomo_num(o.subtomo_num(i)),'.mrc'];
            sg_mrcwrite(name,subtomo,[],'pixelsize',o.output_pixelsize);
    end
        
    
    
    % Check size
    d = dir(name);
    if d.bytes ~= subtomo_size
        error([s.cn,'Error extracting subtomogram ',num2str(o.subtomo_num(i)),'!!! Size is NOT as expected!!!']);
    end
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',o.n_extract,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.cn,'Job progress: ',num2str(pc.c),' out of ',num2str(o.n_extract),' extracted... ',rt_str]);
    end
    
end

% Write out stats
stats_name = [p(idx).rootdir,o.metadir,'tomostats_',s.tomo_num(o.tomo_num),'.csv'];
csvwrite(stats_name,stats);
    
    

