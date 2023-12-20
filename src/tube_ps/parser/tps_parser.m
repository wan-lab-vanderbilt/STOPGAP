function tps_parser(varargin)
%% tps_parser
% Parseinputs to generate a parameter file for STOPGAP tube power specra.
%
% WW 10-2022

%%%% DEBUG
% varargin = {'param_name', 'params/tps_param.star', 'rootdir', '/dors/wan_lab/home/wanw/research/mintu/VUKrios_Apr22/04202022_jacksolp_kendalak_retromer_43-3_META/subtomo/bin4/Position_28/init_ref3', 'tempdir', 'none', 'commdir', 'none', 'refdir', 'none', 'maskdir', 'none', 'listdir', 'none', 'subtomodir', 'none', 'specdir', 'none', 'tps_mode', 'singleref', 'motl_name', 'pos28_motl2_bin4_32.star', 'radlist_name', 'radlist.txt', 'mask_name', 'curved_mask.mrc', 'ps_name', 'tubeps_1.mrc', 'subtomo_name', 'subtomo', 'lp_rad', '14', 'lp_sigma', '3', 'hp_rad', '1', 'hp_sigma', '2', 'apply_laplacian', '0', 'score_thresh', '0'};

%% Generate input parser
% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,param] = sg_get_tps_parameter_arguments;
n_param = size(parser_param,2);

% Add parameters
for i = 1:n_param
    addParameter(parser,parser_param{1,i},[]);
end

% Parse arguments
parse(parser,varargin{:});
p = parser.Results;


%% Check directory names

% Number of directory inputs
n_dir = size(param.dir,2);

for i = 1:n_dir
    % Check if field is filled
    if sg_check_param(p,param.dir{1,i})
        p.(param.dir{1,i}) = sg_check_dir_slash(p.(param.dir{1,i}));
    end
end



%% Check required parameters

% Check paramfile name
if sg_check_empty_field(p.param_name)
    error('ACHTUNG!!! param_name is required!!!');
end

% Check parser_param
for i = 1:n_param
    if isempty(p.(parser_param{1,i})) && strcmp(parser_param{3,i},'req')
        error(['ACHTUNG!!! ',parser_param{1,i},' is required!!!']);
    end
end

% Evalulate non-string inputs
p = parser_evaluate(p,parser_param);


%% Check mode
modes = {'singleref','multiref'};

if ~any(strcmp(p.tps_mode,modes))
    error(['ACHTUNG!!! ',p.tps_mode,' is not a supported tps_mode!!!']);
end

%% Read motivelist and determine tube parameters

% Check listdir
if sg_check_param(p,'listdir')
    listdir = p.listdir;
else
    listdir = 'lists/';
end

% Read motivelist
allmotl = sg_motl_read2([p.rootdir,listdir,p.motl_name]);

% Number of tomograms
tomos = unique(allmotl.tomo_num);
n_tomos = numel(tomos);

% Cell to hold tube arrays
tomo_cell = cell(n_tomos,1);

% Parse objects
for i = 1:n_tomos
    % Find tomo members
    temp_idx = allmotl.tomo_num == tomos(i);
    % Parse tubes within tomogram
    tube_idx = unique(allmotl.object(temp_idx));
    temp_n_tubes = numel(tube_idx);
    % Store tube and tomo IDs
    tomo_cell{i} = cat(2,ones(temp_n_tubes,1).*tomos(i),tube_idx');
end

% Store tube IDs
tubes = vertcat(tomo_cell{:});
n_tubes = size(tubes,1);


%% Generate new parameter file

% Ordered output fields
output_fields = sg_get_ordered_tps_input_fields;

% Add missing output fields
p.completed_p_tps = false;
p.completed_f_tps = false;
p.tomo_num = 0;
p.tube_num = 0;


% Intialize new parameter
new_param = struct();

% Fill fields in order
for i = 1:size(output_fields,1)
    if ~sg_check_empty_field(p.(output_fields{i,1}))
        new_param.(output_fields{i,1}) = p.(output_fields{i,1});
    end
end

% Generate entry for each tomogram
new_param = repmat(new_param,[n_tubes,1]);
for i = 1:n_tubes
%     new_param(i).tomo_num = double(tubes(i,1));
%     new_param(i).tube_num = double(tubes(i,2));
    new_param(i).tomo_num = tubes(i,1);
    new_param(i).tube_num = tubes(i,2);
end




%% Append old param file

% Check for old paramfile and read if it exists
paramname = [parser.Results.rootdir,'/',parser.Results.param_name];
if exist(paramname,'file')        

    % Read old parameter file
    old_param = sg_read_tps_param(p.rootdir,p.param_name);
    
    % Get old fields
    old_fields = fieldnames(old_param);
    
    % Get new fields
    new_fields = fieldnames(new_param);    
    
    % All fields
    fields = union(new_fields,old_fields);
        
    % Fill missing old fields
    old_param = parser_fill_fields(old_param,parser_param,fields);
    
    % Fill missing new fields
    new_param = parser_fill_fields(new_param,parser_param,fields);
    
    % Append parameter file
    new_param = cat(1,old_param,new_param);
    
else
    
    fields = fieldnames(new_param); 
end    

% Double check sorting
n_param_fields = numel(fields);
sorted_fields = cell(n_param_fields,1);
n = 1;
for i = 1:numel(output_fields)
    idx = strcmp(fields,output_fields{i});
    if any(idx)
        sorted_fields{n} = output_fields{i};
        n = n+1;
    end
end

% Re-sort fields
new_param = orderfields(new_param,sorted_fields);





%% Write output

sg_write_tps_param(new_param,p.rootdir,p.param_name);

