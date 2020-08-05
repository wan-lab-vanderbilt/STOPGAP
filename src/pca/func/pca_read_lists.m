function o = pca_read_lists(p,o,idx)
%% pca_read_lists
% Read in lists in preparation for performing PCA.
%
% WW 05-2019


%% Read wedgelist

% Parse name
wname = [p(idx).rootdir,'/',o.listdir,'/',p(idx).wedgelist_name];

% Read file
o.wedgelist = sg_wedgelist_read(wname);
o.pixelsize = o.wedgelist(1).pixelsize*p(idx).binning;
    
    

%% Read in motivelist

% Parse name
motl_name = [p(idx).rootdir,'/',o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration),'.star'];

% Read motivelist
o.allmotl = sg_motl_read2(motl_name);
o.n_motls = numel(o.allmotl.motl_idx);
o.motl_type = sg_motl_check_type(o.allmotl);

% Find all unique motivelist entries        
o.motl_idx = unique(o.allmotl.motl_idx);
o.n_motls = numel(o.motl_idx); 

% Find all unique subtomograms        
o.subtomos = unique(o.allmotl.subtomo_num);
o.n_subtomos = numel(o.subtomos); 



%% Read filter list

fname = [p(idx).rootdir,'/',o.listdir,'/',p(idx).filtlist_name];
o.filtlist = stopgap_star_read(fname,true,[],'stopgap_pca_filt_list');



