function tm_copy_local_temp_data(p,o,s,idx)
%% tm_copy_local_temp_data
% Copy locally stored temporary template matching files to remote storage.
%
% WW 04-2021

%% Copy data

% Return if local copying is disabled
if ~o.copy_local
    return
end

disp([s.cn,'Waiting for template matching to finish on node ',num2str(o.node_id)]);
if o.copy_core
    
    % Wait for remaining cores
    wait_for_them([o.rootdir,'copy_comm/'],['sg_ptm_',o.tomo_num],o.cores_on_node,s.wait_time);
    
    % Rsync data
    disp([s.cn,'Template macthing on node ',num2str(o.node_id),' complete! Copying output tiles from local to remote storage...']);
    tic;
    system(['rsync -a ',o.rootdir,o.tempdir,' ',p(idx).rootdir,o.tempdir]);
    time = toc;
    disp([s.cn,'Tiles copied in ',num2str(time),' seconds!!!']);
    
    % Write completion
    system(['touch ',o.rootdir,'copy_comm/sg_ptm_',o.tomo_num,'_copied']);
    
    
else
    
    % Wait for copying to finish
    wait_for_it([o.rootdir,'copy_comm/'],['sg_ptm_',o.tomo_num,'_copied'],s.wait_time);
    disp([s.cn,'Template macthing on node ',num2str(o.node_id),' complete!']);
    
end






