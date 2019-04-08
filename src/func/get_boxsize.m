function o = get_boxsize(p,o,idx)
%% get_boxsize
% A function to get the boxsize by reading the first subtomogram in the
% motivelist. 
%
% WW 11-2017

%% Get boxsize
name = sprintf([p(idx).subtomoname,'_%0',num2str(p(idx).subtomozeros),'d.em'],o.allmotl(4,1,1));
subtomo = read_em(p(idx).rootdir,name);
o.boxsize = size(subtomo,1); 
o.cen = floor(o.boxsize/2)+1;   
