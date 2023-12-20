function o = extract_read_wedgelist(p,o,s,idx)
%% extract_read_wedgelist
% Read wedgelist if provided.
%
% WW 04-2021

%% Read wedgelist

if sg_check_param(p(idx),'wedgelist_name')
    disp([s.cn,'Reading wedgelist...']);
    
    % Read wedgelist
    o.wedgelist = sg_wedgelist_read([o.rootdir,o.listdir,p(idx).wedgelist_name]);
    
end


