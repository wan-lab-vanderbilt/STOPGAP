function o = load_filter_list(p,o,s,idx)
%%load_filter_list
% Load filter list into o struct.
%
% WW 06-2019

%% Load filter list


fname = [p(idx).rootdir,'/',o.listdir,'/',p(idx).filtlist_name];

try
    o.flist = stopgap_star_read(fname,true,[],'stopgap_pca_filt_list');
catch
    error([s.nn,'ACHTUNG!!! Error reading filter list: ',fname]);
end


o.n_filt = numel(o.flist);