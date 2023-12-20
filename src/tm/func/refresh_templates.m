function o = refresh_templates(p,o,s,idx)
%% refresh_templates
% A function to check for a new template list; if a new one is found,
% templates are reloaded.
%
% WW 03-2019

%% Check check
disp([s.cn,'Checking templates...']);


% Set refresh
refresh = false;

% Check for loaded template list
if isfield(o,'tlist')
    disp([s.cn,'No template list loaded...']);
    refresh = true;
end

% Check for new template list
if idx == 1
    refresh = true;
else
    % Check for different template list
    if ~strcmp(p(idx-1).tlist_name,p(idx).tlist_name)
        disp([s.cn,'New template list detected...']);
        refresh = true;
    end
    
    % Check for changes in bandpass filter
    if s.fourier_crop
        a = p(idx).lp_rad == p(idx-1).lp_rad;
        b = p(idx).lp_sigma == p(idx-1).lp_sigma;
        c = p(idx).hp_rad == p(idx-1).hp_rad;
        d = p(idx).hp_sigma == p(idx-1).hp_sigma;
        if any([a,b,c,d])
            disp([s.cn,'New bandpass filter for Fourier cropped matching...']);
            refresh = true;
        end
    end
end




% Return without refresh
if ~refresh
    disp([s.cn,'Refresh templates skipped...']);
    o.reload_tmpl = false;     % Was template reloaded this iteration
    return
else
    o.reload_tmpl = true;
end


%% Read template list
disp([s.cn,'Refreshing templates!!!']);

% Check for local copy
if o.copy_local   
    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','tlist_copied',1,[o.listdir,p(idx).tlist_name],false);        
end

% Read template list
o.tlist = sg_tm_template_list_read([o.rootdir,'/',o.listdir,'/',p(idx).tlist_name]);
o.n_tmpl = numel(o.tlist);




%% Refresh angles


% Initialize cell arrays
o.ang = cell(o.n_tmpl,1);
o.n_ang = zeros(o.n_tmpl,1);

% Read angles
for i = 1:o.n_tmpl
    
    % Parse anglelist name
    ang_name = [o.listdir,o.tlist(i).anglist_name];
    
    % Check for local copy
    if o.copy_local   
        copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['anglist_',num2str(i),'_copied'],1,ang_name,false);        
    end
    
    % Read angle list
    try
        o.ang{i} = csvread([o.rootdir,ang_name])';
    catch
        error([s.cn,'ACHTUNG!!! Error reading angle list!!!']);
    end
    o.n_ang(i) = size(o.ang{i},2);
    
end





%% Refresh volumes

% Initialize cell arrays
o.tmpl = cell(o.n_tmpl,1);
o.mask = cell(o.n_tmpl,1);

% Read templates and masks
for i = 1:o.n_tmpl
    
    % Parse template name
    tmpl_name = [o.tmpldir,'/',o.tlist(i).tmpl_name];
    
    % Check for local copy
    if o.copy_local   
        copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['tmpl_',num2str(i),'_copied'],1,tmpl_name,false);        
    end

    % Read template
    o.tmpl{i} = read_vol(s,o.rootdir,tmpl_name);

    % Apply symmetry
    o.tmpl{i} = sg_symmetrize_volume(o.tmpl{i},o.tlist(i).symmetry);

    % Check for laplacian
    if sg_check_param(p(idx),'apply_laplacian')
        o.tmpl{i} = del2(o.tmpl{i});
    end

    
    
    % Parse mask name
    mask_name = [o.maskdir,'/',o.tlist(i).mask_name];
    
    % Check for local copy
    if o.copy_local   
        copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/',['mask_',num2str(i),'_copied'],1,mask_name,false);        
    end
    
    % Read mask    
    o.mask{i} = read_vol(s,o.rootdir,mask_name);
    
    
    
end



% Check boxsizes
o.tmpl_size = size(o.tmpl{1},1);
for i = 1:o.n_tmpl
    if any(size(o.tmpl{i},1)~=o.tmpl_size)
        error([s.cn,'ACHTUNG!!! Boxsize mismatch for: ',o.tlist(i).tmpl_name,'!!! Boxsize set to: ',num2str(o.tmpl_size),'!!!']);
    end
    if any(size(o.mask{i},1)~=o.tmpl_size)
        error([s.cn,'ACHTUNG!!! Boxsize mismatch for: ',o.tlist(i).mask_name,'!!! Boxsize set to: ',num2str(o.tmpl_size),'!!!']);
    end
end

    

