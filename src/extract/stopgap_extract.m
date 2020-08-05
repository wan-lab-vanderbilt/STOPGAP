function stopgap_extract(rootdir,param_name,procnum)
%% stopgap_extract
% Read in a motive list and extract subtomograms. Tomogram numbers are read
% from the motivelist, and tomograms are stored in the tomo_dir as
% [tomo_num].rec; leading zeros in the tomogram names are set by
% tomo_digits. Subtomograms are written out as
% [rootdir]/[subtomo_name]_[subtomo_num].em; leading zeros are controlled
% by subtomo_digits. 
%
% WW 08-2018

% % % % DEBUG
% rootdir = '/fs/gpfs03/lv03/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/sg_0.6.1/bin8/init_ref/';
% param_name = 'extract_param.txt';
% procnum = '1';


%% Evaluate numeric inputs

if (ischar(procnum)); procnum=eval(procnum); end


%% Initialize

% Read parameters
p = read_parameters(rootdir,param_name);

% Check format
if isfield(p,'format')
    if ~any(strcmp(p.format,{'em','mrc','mrc16','mrc8'}))
        error('ACHTUNG!!! Unsupported format!!!')
    end
else
    p.format = 'mrc8';
end

% Read motivelist
allmotl = sg_motl_read([p.rootdir,'/',p.motl_dir,'/',p.motl_name]);

% Parse tomograms
tomos = unique([allmotl.tomo_num]);
n_tomos = numel(tomos);

% Check folders
check_folders(p.rootdir,p.subtomo_name,p.comm_dir,'/',p.stats_dir,'/');

% Check for rescaling
if sg_check_param(p,'output_pixelsize')
    if p.output_pixelsize ~= p.pixelsize
        target_scale_factor = p.output_pixelsize/p.pixelsize;
        p.extract_size = round_to_even(p.boxsize*target_scale_factor);

        % Write true pixelsize
        if procnum == 1
            true_scale_factor = p.extract_size/p.boxsize;
            final_pixelsize = p.pixelsize*true_scale_factor;
            pct_error = abs(p.output_pixelsize-final_pixelsize)/p.output_pixelsize;
            fid = fopen([p.rootdir,'/pixelsize.txt'],'w');
            fprintf(fid,['True scaling factor: ',num2str(true_scale_factor),'\n']);
            fprintf(fid,['Final output pixelsize: ',num2str(final_pixelsize),'\n']);
            fprintf(fid,['Pixelsize percent error: ',num2str(pct_error*100)]);
            fclose(fid);
        end
        
    else
        p.extract_size = p.boxsize;
    end
else    
    p.extract_size = p.boxsize;    
end


% Initialize for Fourier rescaling
if p.extract_size ~= p.boxsize    
    f = struct();
    [f.ex_idx,f.box_idx] = calculate_fourier_indices(p.extract_size,p.boxsize);
    f.lpf = initialize_lpf(p.extract_size,p.boxsize);
else 
    f = struct();
end

%% Extract subtomos

for i = procnum:n_tomos
    
    % Check for start
    start_name = [p.rootdir,'/',p.comm_dir,'/start_',num2str(tomos(i))];
    if ~exist(start_name,'file')
        system(['touch ',start_name]);
        disp(['Reading tomogram ',num2str(tomos(i)),'!!!']);        
    else
        continue
    end
    
    % Read tomogram
    tomo_name = sprintf([p.tomo_dir,'/%0',num2str(p.tomo_digits),'d.rec'],tomos(i));
    [tomogram, header] = sg_mrcread(tomo_name);    
    disp(['Tomogram ',num2str(tomos(i)),' read... Extracting subtomograms...']);
    
    % Check for pixelsize
    if sg_check_param(p,'pixelsize')
        pixelsize = p.pixelsize;
    else
        pixelsize = single(header.xlen)/single(header.mx);
    end
    
    % Parse motivelist
    tomo_idx = [allmotl.tomo_num] == tomos(i);
    temp_motl = allmotl(tomo_idx);
    
    % Calcualte extraction coordinates
    coords = calculate_subtomo_coords(tomogram,temp_motl,p.extract_size);
    
    % Extract subtomos
    stats = extract_subtomo(tomogram,pixelsize,temp_motl,coords,[p.rootdir,'/',p.subtomo_dir,'/',p.subtomo_name],p.subtomo_digits,p.extract_size,p.boxsize,p.format,f);
    
    
    % Write out stats
    stats_name = [p.rootdir,'/raw/tomostats_',num2str(tomos(i),['%0',num2str(p.tomo_digits),'d']),'.csv'];
    csvwrite(stats_name,stats);
    
    % Write completion file
    complete_name = [p.rootdir,'/',p.comm_dir,'/done_',num2str(tomos(i))];
    system(['touch ',complete_name]);
    disp(['Tomogram ',num2str(tomos(i)),' extracted!!!one1']);
    
    
end


