function v = initialize_f_avg_volumes(p,o,s,idx,mode,class,iteration)
%% initialize_f_avg_volumes
% Initialize volumes for final averageing.
%
% WW 06-2019

%% Initialize volume names
disp([s.nn,'Initializing volumes for class: ',num2str(class)]);

% Initialize struct
v = struct();

% Generate reference names
v.ref_names = cell(2,1);
v.out_ref_names = cell(3,1);
for i = 1:2
    v.ref_names{i} = get_p_avg_vol_name('ref',o.reflist,char(64+i),mode,class);
    v.out_ref_names{i} = get_f_avg_vol_name('ref',o.reflist,char(64+i),mode,class,iteration);
end
v.out_ref_names{3} = get_f_avg_vol_name('ref',o.reflist,[],mode,class,iteration);


% Generate wfilt names
v.wfilt_names = cell(2,1);
for i = 1:2
    v.wfilt_names{i} = get_p_avg_vol_name('wfilt',o.reflist,char(64+i),mode,class);
end
if s.write_raw
    v.out_wfilt_names = cell(2,1);
    for i = 1:2
        v.out_wfilt_names{i} = get_f_avg_vol_name('wfilt',o.reflist,char(64+i),mode,class,iteration);
    end
end


% Generate power spectrum names
if sg_check_param(p(idx),'ps_name')
    v.ps_names = cell(2,1);
    v.out_ps_names = cell(3,1);
    for i = 1:2
        v.ps_names{i} = get_p_avg_vol_name('ps',o.reflist,char(64+i),mode,class);
        v.out_ps_names{i} = get_f_avg_vol_name(p(idx).ps_name,o.reflist,char(64+i),mode,class,iteration);
    end
    v.out_ps_names{3} = get_f_avg_vol_name(p(idx).ps_name,o.reflist,[],mode,class,iteration);
    
    % Concatenate all names
    v.all_names = cat(1,v.ref_names,v.wfilt_names,v.ps_names);
    
else
    
    % Concatenate all names
    v.all_names = cat(1,v.ref_names,v.wfilt_names);
    
end

% Generate amplitude spectrum names
if sg_check_param(p(idx),'amp_name')
    v.out_amp_names = cell(3,1);
    for i = 1:2
        v.out_amp_names{i} = get_f_avg_vol_name(p(idx).amp_name,o.reflist,char(64+i),mode,class,iteration);
    end
    v.out_amp_names{3} = get_f_avg_vol_name(p(idx).amp_name,o.reflist,[],mode,class,iteration);
end


%% Initializing volumes


% Check for super sampling
if o.avg_ss > 1;
    boxsize = o.ss_boxsize;
else
    boxsize = o.boxsize;
end

for i = 1:numel(v.all_names)
    v.(v.all_names{i}) = zeros(boxsize,'single');
end



