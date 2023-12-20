function extract_copy_subtomograms(p,o,s,idx)
%% extract_copy_subtomograms
% Copy locally extracted tomograms to remote storage.
%
% WW 05-2023

%% Copy subtomograms

if o.copy_local
    
    if o.copy_core
                
        % Copy subtomograms
        disp([s.cn,'Copying extracted subtomograms to remote storage...']);
        system(['rsync -a ',o.rootdir,o.subtomodir,' ',p(idx).rootdir,o.subtomodir]);
        
        
        % Write completion file
        system(['touch ',p(idx).rootdir,o.commdir,'copy_complete_',num2str(idx),'_',num2str(s.node_id)]);        
        disp([s.cn,'Subtomogram copying complete!!!']);
        
    else
        
        % Wait for completion
        wait_for_it([p(idx).rootdir,'/',o.commdir],['copy_complete_',num2str(idx),'_',num2str(s.node_id)],s.wait_time);
        
    end
end



