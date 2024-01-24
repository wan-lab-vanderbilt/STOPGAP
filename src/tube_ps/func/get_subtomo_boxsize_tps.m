function o = get_subtomo_boxsize_tps(p,o,s,idx)
%% get_subtomo_boxsize
% A function to read in the first subtomogram and determine the boxsize.
%
% WW 05-2018

%% Get boxsize

% Parse subtomo name
name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(o.allmotl.subtomo_num(1)),s.vol_ext];

% Check for local copy
if o.copy_local
    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','first_subtomo_copied',s.wait_time,name,false,s.copy_function);
end
    
% Read subtomo
subtomo = read_vol(s,o.rootdir,name);

% Parse boxsize
boxsize = size(subtomo);

% Check for cube
if ~all(boxsize == boxsize(1))
    error([s.node_name,'ACHTUNG!!! Only cubic subtomograms are supported!!!']);
end

% Store single box value
o.boxsize = boxsize(1);

% Calculate box center
o.cen = floor(o.boxsize/2)+1;

