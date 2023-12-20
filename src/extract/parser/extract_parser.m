function extract_parser(varargin)
%% extract_parser
% Parse inputs to generate a parameter file for STOPGAP subtomogram 
% extraction.
%
% WW 01-2019

%%%% DEBUG
% varargin = {'param_name', 'params/extract_param.star', 'rootdir', '/dors/wan_lab/home/wanw/research/HIV_testset/subtomo/vandy/subset_refined/bin1/', 'tomodir', '/dors/wan_lab/home/wanw/research/HIV_testset/tomo/bin1_novactf_refined/', 'motl_name', 'allmotl_1.star', 'boxsize', '192', 'pixelsize', '1.35', 'output_format', 'mrc8' 'read_mode', 'full'};

%% Generate input parser
% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,param] = sg_get_extract_parameter_arguments;
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

% Check paramfile anme
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


%% Check formats

% Check output formats
output_formats = {'em', 'mrc', 'mrc8', 'mrc16' 'mrc32'};
if ~any(strcmp(p.output_format,output_formats))
    error(['ACHTUNG!!! ',p.output_format,' is an unsupported output format!!!']);
end

%% Check pixelsize

if sg_check_param(p,'output_pixelsize')
    if ~sg_check_param(p,'pixelsize') && ~sg_check_param(p,'wedgelist_name')
        error('ACHTUNG!!! For rescaling output pixelsize, either an input pixelsize or wedgelist is required!!!');
    end
end

%% Check tomogram input

if ~sg_check_param(p,'tomodir') && ~sg_check_param(p,'tomolist_name')
    error('ACTHUNG!!! Either the tomodir or a tomolist_name are required!!!');
end


%% Check read mode

% Set reading modes
read_modes = {'full','partial'};

% Check reading mode
if sg_check_param(p,'read_mode')
    if ~any(p.read_mode,redo_modes)
        error('ACHTUNG!!! Unsupported read mode set!!!');
    end
end


%% Generate new parameter file
           
% Ordered output fields
output_fields = sg_get_ordered_extract_input_fields;

% Add missing output fields
p.completed = false;

% Intialize new parameter
new_param = struct();

% Fill fields in order
for i = 1:size(output_fields,1)
    if ~sg_check_empty_field(p.(output_fields{i,1}))
        new_param.(output_fields{i,1}) = p.(output_fields{i,1});
    end
end




%% Append old param file

% Check for old paramfile and read if it exists
paramname = [parser.Results.rootdir,'/',parser.Results.param_name];
if exist(paramname,'file')        

    % Read old parameter file
    old_param = sg_read_extract_param(parser.Results.rootdir,parser.Results.param_name);
    
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

sg_write_extract_param(new_param,parser.Results.rootdir,parser.Results.param_name);

