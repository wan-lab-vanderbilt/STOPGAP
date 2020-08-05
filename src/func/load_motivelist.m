function o = load_motivelist(p,o,s,idx)
%%
% Load motivelist and parse parameters.
%
% WW 06-2019

%% Load motivelist

% Check iteration
iteration = p(idx).iteration;

% Parse mode
if isfield(p(idx),'subtomo_mode')
    mode = strsplit(p(idx).subtomo_mode,'_');
    
    % Increment iteration after alignment
    if strcmp(mode{1},'ali') && p(idx).completed_ali         
        iteration = p(idx).iteration + 1;
    end

end

% Parse motivelist name
o.motl_name = [o.listdir,'/',p(idx).motl_name,'_',num2str(iteration),'.star'];
disp([s.nn,'Loading motivelist: ',o.motl_name]);


% Read motive list
o.allmotl = sg_motl_read2([p(idx).rootdir,o.motl_name]);          

% Find unqiue entries
o.motl_idx = unique(o.allmotl.motl_idx);
o.n_motls = numel(o.motl_idx);

% Find all unique subtomogram entries        
o.subtomos = unique(o.allmotl.subtomo_num);
o.n_subtomos = numel(o.subtomos);

% Parse tomogram information
o.tomos = unique(o.allmotl.tomo_num);
o.n_tomos = numel(o.tomos);

% Parse class information
switch mode{2}
    case 'singleref'
        o.classes = int32(1);
        o.n_classes = 1;
    otherwise
        o.classes = unique(o.allmotl.class);
        o.n_classes = numel(o.classes);
end


% Check motl type
o.motl_type = sg_motl_check_type(o.allmotl,2);        



