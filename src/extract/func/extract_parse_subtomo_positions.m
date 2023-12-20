function o = extract_parse_subtomo_positions(p,o,s,idx)
%% extract_parse_subtomo_positions
% Parse positions from motivelist for tomogram to be extracted.
%
% WW 04-2021

%% Parse subtomogram indices
disp([s.cn,'Parsing positions for tomogram ',num2str(o.tomo_num)]);

% Parse indices for tomogram
tomo_idx = o.allmotl.tomo_num == o.tomo_num;
temp_motl = sg_motl_parse_type2(o.allmotl,tomo_idx);

% Determine unique subtomograms
[~,unique_idx] = unique(temp_motl.subtomo_num);
if numel(unique_idx) ~= numel(temp_motl.subtomo_num)
    warning([s.cn,'ACHTUNG!!! Multiple motivelist entries for subtomogram numbers... Only first entries will be used for extraction!!!']);
    
    % Parse positions
    o.subtomo_num = temp_motl.subtomo_num(unique_idx);
    x = temp_motl.orig_x(unique_idx);
    y = temp_motl.orig_y(unique_idx);
    z = temp_motl.orig_z(unique_idx);
    
else
    
    % Parse positions
    o.subtomo_num = temp_motl.subtomo_num;
    x = temp_motl.orig_x;
    y = temp_motl.orig_y;
    z = temp_motl.orig_z;
    
end
o.n_extract = numel(o.subtomo_num);
disp([s.cn,'Extracting ',num2str(o.n_extract),' subtomograms from tomogram ',num2str(o.tomo_num),'!!!']);



%% Calcualte extraction coordinates

% Parse tomogram dimensions
tomo_x = single(o.tomo_header.nx);
tomo_y = single(o.tomo_header.ny);
tomo_z = single(o.tomo_header.nz);

% Extraction center
tc = floor(cat(1,x',y',z'));

% Initialize coordinate struct
o.coords = struct();

% Extraction starting indices
o.coords.es = tc - floor(p(idx).boxsize/2);

% Extraction ending indices
o.coords.ee = o.coords.es + p(idx).boxsize - 1;


% Subtomo indices
o.coords.ss = ones(3,o.n_extract);
o.coords.se = ones(3,o.n_extract).*p(idx).boxsize;


% Check for out of starting bounds
d_start = 1-o.coords.es;
d_start_idx = d_start>0;
o.coords.ss(d_start_idx) = o.coords.ss(d_start_idx) + d_start(d_start_idx);
o.coords.es(d_start_idx) = 1;

% Check for out of starting bounds
end_array = repmat([tomo_x;tomo_y;tomo_z],[1,o.n_extract]);
d_end = end_array - o.coords.ee;
d_end_idx = d_end<0;
o.coords.ee(d_end_idx) = end_array(d_end_idx);
o.coords.se(d_end_idx) = o.coords.se(d_end_idx) + d_end(d_end_idx);

