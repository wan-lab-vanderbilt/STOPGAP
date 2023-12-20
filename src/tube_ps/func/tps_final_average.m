function tps_final_average(p,o,s,idx)
%% tps_final_average
% A function to average the output from parallel tube power spectrum
% calculations.
%
% WW 10-2022

%% Initialize

disp([s.cn,'Begin final parallel averaging for tube power spectra ',num2str(o.f_tps_class),'!!!']);



% Determine number of subtomograms per average
n_subtomos = determine_subtomograms_per_parallel_ps(p,o,idx);

% Parse tube radius
tomo_idx = o.radlist(:,1) == p(idx).tomo_num;
tube_idx = o.radlist(:,2) == p(idx).tube_num;
tube_radius = o.radlist((tomo_idx&tube_idx),3);

% Initialize an array with size of box padded by radius on either side
tube_edge = (2*tube_radius) + o.boxsize;

% Initialize volume array to store cylindrical polar slices
r = (tube_edge/2); % Radial slice dimension
a = (tube_edge*2); % Azimuthal angle


% PS types
ps_types = {'unfilt','filt'};

%% Perform final averaging

% Loop through each class to be averaged
for i = 1:o.n_f_tps_class
    disp([s.cn,'Beginning averaging on class: ',num2str(o.f_tps_class(i))]);
    
    % Parse class ID
    class = o.f_tps_class(i);
           
    % Get class index
    class_idx = reshape((o.classes == class),[],1);

        
    %%%%% Generate averages %%%%%
    disp([s.cn,'Summing partial averages...']);
    
    
    
    %%%%% Sum volumes %%%%%

    % Initialize amplitude volumes
    amp = struct();
    amp.unfilt = zeros(o.boxsize,a,r);
    amp.filt = zeros(o.boxsize,a,r);
    
    % Initialize counter
    pc = struct();
    pc = progress_counter(pc,'init',o.total_p_tps_cores,s.counter_pct);
    
    
    for j = reshape(o.p_tps_procnums,1,[])
        
        
        % Parse parallel name
        name = struct();
        switch p(idx).tps_mode
            case 'singleref'
                name.unfilt = [o.tempdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(o.procnum),s.vol_ext];
                name.filt = [o.tempdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(o.procnum),s.vol_ext];
            otherwise
                name.unfilt = [o.tempdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
                name.filt = [o.tempdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),'_',num2str(o.procnum),s.vol_ext];
        end
        
        
        
        % Sum amplitudes
        for k = 1:2
            amp.(ps_types{i}) = amp.(ps_types{i}) + read_vol(s,p(idx).rootdir,name.(ps_types{i}));
        end
        
        
        
        
        % Increment completion counter
        [pc,rt_str] = progress_counter(pc,'count',o.total_p_tps_cores,s.counter_pct);
        if ~isempty(rt_str)
            disp([s.cn,'Job progress: ',num2str(pc.c),' out of ',num2str(o.total_p_tps_cores),' for class ',num2str(class),' averaged... ',rt_str]);
        end

    end
    
    
    % Divide to get average
    for k = 1:2
%         amp.(ps_types{i}) = amp.(ps_types{i})./n_subtomos(class_idx);
        amp.(ps_types{i}) = (amp.(ps_types{i})-mean(amp.(ps_types{i})(:)))./std(amp.(ps_types{i})(:));
    end
    
    
    
    
    %%%%% Write Output Volumes %%%%%
    disp([s.cn,'Power spectrum calculation of class ',num2str(class),' complete!!! Writing outputs...']);
    
    % Parse output names
    switch p(idx).tps_mode
        case 'singleref'
            unfilt_name = [o.specdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),s.vol_ext];
            filt_name = [o.specdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),s.vol_ext];
        otherwise
            unfilt_name = [o.specdir,p(idx).ps_name,'_unfilt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),s.vol_ext];
            filt_name = [o.specdir,p(idx).ps_name,'_filt_',num2str(p(idx).tomo_num),'_',num2str(p(idx).tube_num),'_',num2str(class),s.vol_ext];
    end
    
    % Write outputs
    write_vol(s,o,p(idx).rootdir,unfilt_name,amp.unfilt);
    write_vol(s,o,p(idx).rootdir,filt_name,amp.filt);
    
    
    % Write checkjob
    system(['touch ',p(idx).rootdir,'/',o.commdir,'/sg_f_tps_',num2str(o.f_tps_class(i))]);
    
    
    disp([s.cn,'Tube power spectrum calculation for class ',num2str(o.f_tps_class(i)),'complete!!!']);
end

disp([s.cn,'All classes averaged!!!']);

    


