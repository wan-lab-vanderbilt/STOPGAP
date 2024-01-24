function o = get_subtomo_boxsize(p,o,s,idx)
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

% Determine and store boxsize
o.boxsize = size(subtomo);

% Calculate box center
o.cen = floor(o.boxsize/2)+1;

