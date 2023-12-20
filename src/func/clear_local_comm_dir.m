function clear_local_comm_dir(o,s)
%% clear_local_comm_dir
% Clear local communication directory. For non-copy cores, a breif wait is
% added.
%
% WW 03-2021

%% Clear directory
if isempty(s.copy_local)
    s.copy_local = false;
end
if ~isfield(s,'copy_local')
    s.copy_local = false;
end
if ~s.copy_local
    return
end

disp([s.cn,'copy_local debug :',s.copy_local]);


if sg_check_param(s,'copy_local')
    
    if o.copy_core
        disp([s.cn,'Clearing local comm directory...']);

        % Clear copy-communications directory
        system(['mkdir -p ',o.rootdir,'copy_comm/']);
        system(['rm -rf ',o.rootdir,'copy_comm/*']);

        % Reinitialization complete
        system(['touch ',o.rootdir,'/copy_comm/reinit_complete']);

    else

        % Wait for copy core to clear local comm direcotry
        wait_for_it([o.rootdir,'/copy_comm/'],'reinit_complete',s.wait_time);

    end

end


