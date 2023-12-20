function o = extract_initialize_motivelist(p,o,s,idx)
%% extract_initialize_motivelist
% A function to initialize a motivelist prior to subtomogram extraction.
%
% WW 04-2021

%% Initialize motivelist
disp([s.cn,'Initializing motivelist!!!']);


% Read motivelist
motl_name = [o.rootdir,o.listdir,p(idx).motl_name];
o.allmotl = sg_motl_read2(motl_name);   

% % Parse tomograms
% o.tomo_num = unique(o.allmotl.tomo_num);
% o.n_tomos = numel(o.tomo_num);


%% Generate tomolist

% Check for tomolist
if sg_check_param(p(idx),'tomolist_name')
    disp([s.cn,'Reading tomolist...']);
    
    % Read tomolist
    tomolist_name = [o.rootdir,'/',o.listdir,p(idx).tomolist_name];
    tomolist = read_extract_tomolist(tomolist_name);
    
    % Check intersection between list and allmotl
    motl_tomos = unique(o.allmotl.tomo_num);
    o.n_tomos = numel(motl_tomos);
    [~,t_idx,~] = intersect(tomolist.tomo_num,motl_tomos);
    
    % Parse tomolist
    o.tomolist.tomo_num = tomolist.tomo_num(t_idx);
    o.tomolist.tomo_name = tomolist.tomo_name(t_idx);
    
else
    disp([s.cn,'Generating tomolist...']);
    
    % Initialize tomolist
    o.tomolist = struct();
    o.tomolist.tomo_num = unique(o.allmotl.tomo_num);
    o.n_tomos = numel(o.tomolist.tomo_num);
    o.tomolist.tomo_name = cell(o.n_tomos,1);
    
    
    % Fill tomolist
    for i = 1:o.n_tomos
        o.tomolist.tomo_name{i} = [p(idx).tomodir,'/',s.tomo_num(o.tomolist.tomo_num(i)),'.',s.tomo_ext];
    end
end



