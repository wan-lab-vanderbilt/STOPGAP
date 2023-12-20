function o = tps_load_motl(p,o,s,idx)
%% tps_load_motl
% Load motivelist for calculating tube power spectra.
%
% WW 10-2022

%% Initialize motivelist
disp([s.cn,'Initializing motivelist!!!']);

% Parse motivelist name
o.motl_name = [o.listdir,p(idx).motl_name];

% Check for local copy
if o.copy_local
    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','motivelist_copied',s.wait_time,o.motl_name,false);
end

% Read full motive list
allmotl = sg_motl_read2([o.rootdir,o.motl_name]);    
allmotl = sg_sort_motl2(allmotl); % Resort 

% Parse tube motl
tomo_idx = allmotl.tomo_num == p(idx).tomo_num;
tube_idx = allmotl.object == p(idx).tube_num;
o.allmotl = sg_motl_parse_type2(allmotl,tomo_idx&tube_idx);

% Find unqiue entries
o.motl_idx = unique(o.allmotl.motl_idx);
o.n_motls = numel(o.motl_idx);

% Parse class information
switch p(idx).tps_mode
    case 'singleref'
        o.classes = int32(1);
        o.n_classes = 1;
    otherwise            
        o.classes = unique(o.allmotl.class);
        o.n_classes = numel(o.classes);
end

%% Load radii list

% Parse name
o.radlist_name = [o.listdir,p(idx).radlist_name];

% Check for local copy
if o.copy_local
    copy_file_to_local_temp(o.copy_core,p(idx).rootdir,o.rootdir,'copy_comm/','motivelist_copied',s.wait_time,o.radlist_name,false);
end

% Load radlist
o.radlist = dlmread([o.rootdir,o.radlist_name]);




