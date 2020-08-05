function pca_prerotate_volumes(p,o,s,idx)
%% pca_prerotate_volumes
% Prerotate subtomograms and filters prior to PCA.
%
% WW 05-2019

%% Intialize

% Initialize filters
f = initialize_subtomo_filters(p,o,s,idx,'avg');

% Calculate low pass filter, this filter takes out the last few high frequency pixels    
lowpass = calculate_3d_bandpass_filter(o.boxsize,(floor(max(o.boxsize)./2)-4),2,0,0);   % Without this, there are edge effects in final volume

% Parallel job parameters
[p_start, p_end] = job_start_end(o.n_subtomos, o.n_cores, o.procnum);
n_p_subtomo = p_end - p_start + 1;

% Initialize status writing
system(['rm -f ',p(idx).rootdir,'/',o.commdir,'/','rotvolprog_',num2str(o.procnum)]);
status = fopen([p(idx).rootdir,o.commdir,'rotvolprog_',num2str(o.procnum)],'w');





%% Rotate volumes

% Initialize counter
pc = struct();
pc = progress_counter(pc,'init',n_p_subtomo,s.counter_pct);


for i = p_start:p_end
    
    %%%%% Parse motivelist %%%%%
    
    % Find best scoring entry for subtomogram
    motl_idx = o.allmotl.subtomo_num == o.subtomos(i);
    motl = parse_motl(o.allmotl,motl_idx);
    [~,top_idx] = max(motl.score);
    rmotl = parse_motl(motl,top_idx);
    
    % Parse parameters
    x = rmotl.x_shift;
    y = rmotl.y_shift;
    z = rmotl.z_shift;
    phi = rmotl.phi;
    psi = rmotl.psi;
    the = rmotl.the;
    
    
     
    %%%%% Read subtomogram %%%%%

    % Read subtomogram
    subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(o.subtomos(i)),s.vol_ext];
    try
        subtomo = read_vol(s,p(idx).rootdir,subtomo_name);
    catch
        error([s.nn,'ACHTUNG!!! Error reading file ',subtomo_name,'!!!']);
    end
    
    % Normalize subtomogram
    subtomo = (subtomo - mean(subtomo(:)))./std(subtomo(:));
    

    % Refresh filters
    f = refresh_subtomo_filters(p,o,s,f,idx,rmotl,'avg');
    
    
    
    
    %%%%% Rotate and symmetrize volumes %%%%%
    
    % Rotate volumes
    subtomo = sg_rotate_vol(sg_shift_vol(subtomo,[-x,-y,-z]),[-psi,-phi,-the],[],'cubic');
    r_pfilt = sg_rotate_vol(f.pfilt,[-psi,-phi,-the],[],'linear');
    r_rfilt = sg_rotate_vol(f.rfilt,[-psi,-phi,-the],[],'linear');
    
    % Filter subtomogram    
    subtomo = real(ifftn(fftn(subtomo).*ifftshift(r_pfilt)));   % Clear missing wedge noise prior to symmetrization
    
    % Symmetrize volumes
    subtomo = sg_symmetrize_volume(subtomo,p(idx).symmetry);
    r_pfilt = sg_symmetrize_volume(r_pfilt,p(idx).symmetry,[],[],false,true);         % Used to clear missing wedge noise again
    r_rfilt = sg_symmetrize_volume(r_rfilt,p(idx).symmetry,[],[],false,false);        % Will downweight undersampled regions like symmetrization
    
    % Perform Fourier re-weighting
    f_idx = r_pfilt>0;              % Sampled regions
    r_pfilt(f_idx) = (1./r_pfilt(f_idx));  % Generate re-weighting filter
    subtomo = real(ifftn(fftn(subtomo).*ifftshift(r_pfilt).*lowpass));
    
    
    
    %%%%% Write outputs %%%%%
    
    % Write volumes
    rvol_name = [o.rvoldir,'/',p(idx).rvol_name,'_',num2str(rmotl.subtomo_num),'.mrc'];
    write_vol(s,o,p(idx).rootdir,rvol_name,subtomo);
    rfilt_name = [o.rvoldir,'/',p(idx).rwei_name,'_',num2str(rmotl.subtomo_num),'.mrc'];
    write_vol(s,o,p(idx).rootdir,rfilt_name,ifftshift(r_rfilt));
    
    % Write counter
    fprintf(status,'%s \n',num2str(rmotl.subtomo_num));
    
    
    % Increment completion counter
    [pc,rt_str] = progress_counter(pc,'count',n_p_subtomo,s.counter_pct);
    if ~isempty(rt_str)
        disp([s.nn,'Job progress: ',num2str(pc.c),' out of ',num2str(n_p_subtomo),' subtomograms rotated... ',rt_str]);
    end
    
end
        
    
%% Write outputs

% Close status
fclose(status);

% Write completion
system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_pca_rotvol_',num2str(o.procnum)]);
disp([s.nn,'Parallel pre-rotation completed!!!1!']);



