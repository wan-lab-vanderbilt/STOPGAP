function final_average(p,o,s,idx)
%% final_average
% A function to generate a weighted average in parallel. The
% parallelization is performed in two steps: a parallel step where a
% number of cores generate partial averages, and a final step that averages
% the parallel averages. 
%
% WW 06-2019

%% Initialize

disp([s.nn,'Begin final parallel averaging for class ',num2str(o.f_avg_class),'!!!']);

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');


% Determine iteration
if strcmp(mode{1},'ali') && p(idx).completed_ali         
    iteration = p(idx).iteration + 1;
else
    iteration = p(idx).iteration;
end

% Determine number of subtomograms per average
n_subtomos = determine_subtomograms_per_average(p,o,idx);

% Initialize mask/filter struct
m = struct();

% Check Fourier threshold
if ~sg_check_param(p(idx),'fthresh')
    m.fthresh = s.fthresh;
else
    m.fthresh = p(idx).fthresh;
end

% Real space mask to prevent edge artifacts
% m.cube_mask = sg_cube_mask(o.ss_boxsize,3*o.avg_ss);
m.cube_mask = sg_cube_mask(o.boxsize,3);

% Calculate low pass filter, this filter takes out the last few high frequency pixels
m.lpf = calculate_3d_bandpass_filter(o.boxsize,(floor(max(o.boxsize)./2)-4),2,0,0);

% Inidices for Fourier cropping 
if o.avg_ss > 1
    ss_f_idx = calculate_3d_fcrop_idx(o.ss_boxsize,o.boxsize);
end

%% Perform final averaging

% Loop through each class to be averaged
for i = 1:o.n_f_avg_class
    disp([s.nn,'Beginning final averaging on class: ',num2str(o.f_avg_class(i))]);
    
    
    
    %%%%% Parse information and initialize %%%%%
    
    % Get class index
    class_idx = reshape((o.classes == o.f_avg_class(i)),[],1);
    
    % Parse symmetry
    sym = o.reflist([o.reflist.class]==o.f_avg_class(i)).symmetry;
    
    % Initialize volumes
    v = initialize_f_avg_volumes(p,o,s,idx,mode,o.f_avg_class(i),iteration);
    
    
    
    %%%%% Check if class has emptied %%%%%
    if any(n_subtomos(class_idx,:)==0)
        
        % Write outputs
        declare_empty_class(p,o,s,v,idx,o.classes(class_idx));
        
        % Write checkjob
        system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_f_avg_',num2str(o.f_avg_class(i))]);
        
        % Continue to next class
        disp([s.nn,'Continuning to next averaging class...']);
        continue
    end
    
        
    
    
    
    %%%%% Generate averages %%%%%
    disp([s.nn,'Summing partial averages...']);
    
    % Sum volumes
    for j = 1:numel(v.all_names)
        
        % Loop through cores
        for k = reshape(o.p_avg_cores,1,[])
    
            % Add volume
            vol_name = [o.tempdir,'/',v.all_names{j},'_',num2str(k),s.vol_ext];
            v.(v.all_names{j}) = v.(v.all_names{j}) + read_vol(s,p(idx).rootdir,vol_name);
            
        end
        
        % Divide to get mean
        if mod(j,2)
            h = 1;
        else
            h = 2;
        end
        v.(v.all_names{j}) = v.(v.all_names{j})/n_subtomos(class_idx,h);
        
        % Downsample
        if o.avg_ss > 1
            v.(v.all_names{j}) = fourier_crop_volume(v.(v.all_names{j}),ss_f_idx);
        end
        
    end
    
    % Fourier reweight volumes
    v = fourier_reweight_averages(p,o,v,m,idx);
    
    
    %%%%% Post process %%%%%
    disp([s.nn,'Calculating FSC...']);
    
    % Calculate FSC
    [corr_fsc,fsc,mean_rfsc] = calculate_fsc(v.(v.ref_names{1}),v.(v.ref_names{2}),o.mask{class_idx},sym,s.fsc_fourier_cutoff,s.fsc_n_repeats);
    save_fsc_plot(p,o,v,idx,corr_fsc,fsc,mean_rfsc);
    
    % Check FSC
    if any(isnan(corr_fsc)) || any(isinf(corr_fsc))
        corr_fsc = ones(size(corr_fsc),'single');   % No FOM-weighting for problematic FSCs
    end
    
    % Calculate Figure-of-Merit weighted average
    fom_avg = apply_fom_weighting(v.(v.ref_names{1}),v.(v.ref_names{2}),corr_fsc);
    
    
    
    %%%%% Write outputs %%%%%
    disp([s.nn,'Writing output files...']);
    
    % Loop through halfsets
    for j = 1:2
        
        % Write reference
        name = [o.refdir,'/',v.out_ref_names{j},s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,v.(v.ref_names{j}));
        
        % Write wfilt
        if s.write_raw
            name = [o.rawdir,'/',v.out_wfilt_names{j},s.vol_ext];
            write_vol(s,o,p(idx).rootdir,name,v.(v.wfilt_names{j}));
        end
        
        % Write powerspec
        if sg_check_param(p(idx),'ps_name')
            name = [o.specdir,'/',v.out_ps_names{j},s.vol_ext];
            write_vol(s,o,p(idx).rootdir,name,fftshift(v.(v.ps_names{j})));
        end
        
        % Write amplitude spectra
        if sg_check_param(p(idx),'amp_name')
            name = [o.specdir,'/',v.out_amp_names{j},s.vol_ext];
            write_vol(s,o,p(idx).rootdir,name,abs(fftshift(fftn(v.(v.ref_names{j})))));
        end
    end
    
    % Write average ref
    name = [o.refdir,'/',v.out_ref_names{3},s.vol_ext];
    write_vol(s,o,p(idx).rootdir,name,fom_avg);
    
    % Write average powerspec
    if sg_check_param(p(idx),'ps_name')
        name = [o.specdir,'/',v.out_ps_names{3},s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,fftshift((v.(v.ps_names{1})+v.(v.ps_names{2}))./2));
    end
    
    % Write average amplitude spectra
    if sg_check_param(p(idx),'amp_name')
        name = [o.specdir,'/',v.out_amp_names{3},s.vol_ext];
        write_vol(s,o,p(idx).rootdir,name,abs(fftshift(fftn((v.(v.ref_names{1})+v.(v.ref_names{2}))./2))));
    end
    
    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_f_avg_',num2str(o.f_avg_class(i))]);
    
    
    disp([s.nn,'Final averaging for class ',num2str(o.f_avg_class(i)),'complete!!!']);
end

disp([s.nn,'All classes averaged!!!']);

    


