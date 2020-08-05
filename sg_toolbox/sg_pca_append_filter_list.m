function sg_pca_append_filter_list(filtlist_name,lp_rad,lp_sigma,hp_rad,hp_sigma)
%% sg_pca_append_filter_list
% A function to add an entry to a STOPGAP PCA filter list. 
%
% WW 05-2019

%% Append list

if exist(filtlist_name,'file')
    
    % Append old list    
    filtlist = stopgap_star_read(filtlist_name,true,[],'stopgap_pca_filt_list');
    idx = numel(filtlist)+1;
    
    % Concatenate list
    filtlist = cat(1,filtlist,struct('filt_idx',idx,'lp_rad',lp_rad,'lp_sigma',lp_sigma,'hp_rad',hp_rad,'hp_sigma',hp_sigma));
else
    
    % Generate new list
    filtlist = struct('filt_idx',1,'lp_rad',lp_rad,'lp_sigma',lp_sigma,'hp_rad',hp_rad,'hp_sigma',hp_sigma);
end


%% Write output

stopgap_star_write(filtlist,filtlist_name,'stopgap_pca_filt_list', [], 4, 2);







