function o = get_subtomo_boxsize(p,o,s,idx)
%% get_subtomo_boxsize
% A function to read in the first subtomogram and determine the boxsize.
%
% WW 05-2018

%% Get boxsize

% Read subtomo
name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(o.allmotl.subtomo_num(1)),s.vol_ext];
subtomo = read_vol(s,p(idx).rootdir,name);

% Determine and store boxsize
o.boxsize = size(subtomo);

% Calculate box center
o.cen = floor(o.boxsize/2)+1;

