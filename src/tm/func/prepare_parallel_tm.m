function o = prepare_parallel_tm(p,o,s,idx)
%% 
% Initialize job parameters for parallel template matching.
%
% WW 01-2019



%% Initialize volumes for run
disp([s.cn,'Initialing parameters for parallel template matching...']);

% Check for local copy
if o.copy_local  
    
    % Parse filename
    [path,name,ext] = fileparts(p(idx).tomo_name);  % Parse remote path
    tomo_file_name = [name,ext];                    % Parse filename
    o.tomo_name = [o.rootdir,tomo_file_name];       % Generate local path
    
    % Copy tomogram    
    if o.copy_core
        disp([s.cn,'Copying tomogram ',o.tomo_name,' to local temporary directory...']);
        time = copy_file_to_local_temp(o.copy_core,[path,'/'],o.rootdir,'copy_comm/',['tomo_',num2str(p(idx).tomo_num),'_copied'],s.wait_time,tomo_file_name,false,s.copy_function);        
        disp([s.cn,'Tomogram copied in ',num2str(time),' seconds!!!']);
    else 
        disp([s.cn,'Waiting for tomogram ',o.tomo_name,' to be copied to local temporary directory...']);
        copy_file_to_local_temp(o.copy_core,[path,'/'],o.rootdir,'copy_comm/',['tomo_',num2str(p(idx).tomo_num),'_copied'],s.wait_time,tomo_file_name,false,s.copy_function);        
    end
    
    
    % Check for tomogram mask
    if sg_check_param(p(idx),'tomo_mask_name')
        
        % Parse filename
        [path,name,ext] = fileparts(p(idx).tomo_mask_name);  % Parse remote path
        tomo_mask_file_name = [name,ext];                         % Parse filename
        o.tomo_mask_name = [o.rootdir,tomo_mask_file_name];            % Generate local path
        
        % Copy tomogram mask
        if o.copy_core
            disp([s.cn,'Copying tomogram ',o.tomo_mask_name,' to local temporary directory...']);
            time = copy_file_to_local_temp(o.copy_core,[path,'/'],o.rootdir,'copy_comm/',['tomo_',num2str(p(idx).tomo_num),'mask_copied'],s.wait_time,tomo_mask_file_name,false,s.copy_function);        
            disp([s.cn,'Tomogram copied in ',num2str(time),' seconds!!!']);
        else 
            disp([s.cn,'Waiting for tomogram ',o.tomo_mask_name,' to be copied to local temporary directory...']);
            copy_file_to_local_temp(o.copy_core,[path,'/'],o.rootdir,'copy_comm/',['tomo_',num2str(p(idx).tomo_num),'mask_copied'],s.wait_time,tomo_mask_file_name,false,s.copy_function);        
        end
    end
      
    
    
else
    
    % Set remote path
    o.tomo_name = p(idx).tomo_name;
    if sg_check_param(p(idx),'tomo_mask_name')
        o.tomo_mask_name = p(idx).tomo_mask_name;
    end
end


% Get tomogram header
header = sg_read_mrc_header(o.tomo_name);

% Parse tomogram size
o.tomo_size = double([header.nx,header.ny,header.nz]);

% Check for masked regions
if sg_check_param(p(idx),'tomo_mask_name')
    o = tm_check_mask(p,o,s,idx);
elseif isfield(o,'bounds')
    o = rmfield(o,'bounds');
end

% Parse tomogram number
o.tomo_num = num2str(p(idx).tomo_num);

    
%% Generate job parameters

% % Check scoring function
% if sg_check_param(p(idx),'scoring_fcn')
%     o.scoring_fcn = p(idx).scoring_fcn;
% else
%     o.scoring_fcn = 'flcf';
% end

% Determine box sizes
o = determine_tile_size(p,o,s,idx);

% Get tile coordinates
o = get_tm_coords(p,o,idx);

% Prepare matchlist
o = prepare_matchlist(p,o,s,idx);










