function splitmotl = initialize_splitmotl(o)
%% initialize_splitmotl
% Initialize a struct array for holding partial motl data during 
% subtomogram alignment.
%
% WW 04-2019

%% Initialize motl

% Determine indices
motl_idx = ismember(o.allmotl.motl_idx,o.ali_motl);

% Parse motivelist
splitmotl = parse_motl(o.allmotl,motl_idx);

% Check sorting
sort_array = cat(2,splitmotl.motl_idx,splitmotl.class);
[~,sort_idx] = sortrows(sort_array,[1,2]);

          
      