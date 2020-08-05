function final_vmap(p,o,s,idx)
%% final_vmap
% A function to generate a weighted variance map from parallel
% calculations.
%
% WW 09-2019

%% Initialize
disp([s.nn,'Calculate variance map for class ',num2str(o.f_avg_class),'!!!']);


% Number of subtomograms in each class
n_subtomos = determine_subtomograms_per_vmap(p,o,idx);


% Initialize mask/filter struct
m = struct();

% Check Fourier threshold
if ~sg_check_param(p(idx),'fthresh')
    m.fthresh = s.fthresh;
else
    m.fthresh = p(idx).fthresh;
end

% Real space mask to prevent edge artifacts
m.cube_mask = sg_cube_mask(o.boxsize,3);

% Calculate low pass filter, this filter takes out the last few high frequency pixels
m.lpf = calculate_3d_bandpass_filter(o.boxsize,(floor(max(o.boxsize)./2)-4),2,0,0);


%% Sum volumes

for i = 1:o.n_f_avg_class
    
    %%%%% Sum volumes %%%%%
    
    % Initialize volumes
    vmap = zeros(o.boxsize,'single');
    wei = zeros(o.boxsize,'single');
    
    
    % Loop through parallel cores
    for j = 1:o.n_cores

        % Parse names
        switch p(idx).vmap_mode
            case 'singleref'
                vmap_name = [o.tempdir,'/vmap_',num2str(j),s.vol_ext];
                wei_name = [o.tempdir,'/wei_',num2str(j),s.vol_ext];
            case 'multiclass'
                vmap_name = [o.tempdir,'/p_vmap_',num2str(o.f_avg_class),'_',num2str(j),s.vol_ext];
                wei_name = [o.tempdir,'/p_vmap_',num2str(o.f_avg_class),'_',num2str(j),s.vol_ext];
        end

        % Sum volumes
        vmap = vmap + read_vol(s,p(idx).rootdir,vmap_name);
        wei = wei + read_vol(s,p(idx).rootdir,wei_name);

    end
    
    
    
    %%%%% Weighted averaging %%%%%
    
    % Average volumes
    class_idx = o.classes == o.f_avg_class(i);
    vmap = vmap./n_subtomos(class_idx);
    wei = wei./n_subtomos(class_idx);
    
    % Fourier reweight volumes
    final_vmap = fourier_reweight_vmaps(p,o,idx,o.f_avg_class(i),vmap,wei,m);
    
    
    
    %%%%% Write outputs %%%%%
        
    % Parse names
    switch p(idx).vmap_mode
        case 'singleref'
            vmap_name = [o.refdir,p(idx).vmap_name,'_',num2str(p(idx).iteration),s.vol_ext];
        case 'multiclass'
            vmap_name = [o.refdir,p(idx).vmap_name,'_',num2str(p(idx).iteration),'_',num2str(o.f_avg_class),s.vol_ext];
    end
    
    % Write final vmap
    write_vol(s,o,p(idx).rootdir,vmap_name,final_vmap);
    

    % Write raw files
    if sg_check_param(p(idx),'write_raw')

        % Parse names
        switch p(idx).vmap_mode
            case 'singleref'
                vmap_name = [o.rawdir,'unfiltered_',p(idx).vmap_name,'_',num2str(p(idx).iteration),s.vol_ext];
                wei_name = [o.rawdir,'weights_', p(idx).vmap_name,'_',num2str(p(idx).iteration),s.vol_ext];
            case 'multiclass'
                vmap_name = [o.rawdir,'unfiltered_',p(idx).vmap_name,num2str(p(idx).iteration),'_',num2str(o.f_avg_class),s.vol_ext];
                wei_name = [o.rawdir,'weights_',p(idx).vmap_name,num2str(p(idx).iteration),'_',num2str(o.f_avg_class),s.vol_ext];
        end

        % Write volume
        write_vol(s,o,p(idx).rootdir,vmap_name,vmap);
        write_vol(s,o,p(idx).rootdir,wei_name,wei);

    end

    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_f_vmap_',num2str(o.f_avg_class(i))]);
    disp([s.nn,'Final averaging on class ',num2str(o.f_avg_class(i)),' completed!!!1!']);
    
end

disp([s.nn,'All classes averaged!!!']);


