function o = refresh_wedgelist(p,o,s,idx)
%% refresh_wedgelist
% Check if wedgelist is loaded and unchanged. Otherwise, reload wedgelist
% to 'o' struct.
%
% WW 05-2018

%% Check for reading
disp([s.nn,'Refreshing wedgelist...']);

refresh = false;

if ~isfield(o,'wedgelist') || (idx == 1)
    refresh = true;
elseif ~strcmp([o.listdir,'/',p(idx).wedgelist_name],[o.listdir,'/',p(idx-1).wedgelist_name])
    o = rmfield(o,{'wedgelist','pixelsize','unbinned_pixelsize'});  % Clear old
    refresh = true;
end


%% Read wedgelist

if refresh
    
    % Read wedgelist
    o.wedgelist = sg_wedgelist_read([p(idx).rootdir,o.listdir,'/',p(idx).wedgelist_name],'compact');
    
    % Calculate and check pixelsize
    if ~all([o.wedgelist.pixelsize] == o.wedgelist(1).pixelsize)
        error('ACHTUNG!!! Not all pixelsizes in wedgelist are the same!!!');
    end

    o.pixelsize = o.wedgelist(1).pixelsize.*p(idx).binning;
    o.unbinned_pixelsize = o.wedgelist(1).pixelsize;
end


    
