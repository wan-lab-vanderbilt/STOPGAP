function stopgap_vmap_parser(varargin)
%% stopgap_vmap_parser
% A function to take set of input arguments for calculating a variance map
% using a reference and it's input subtomograms, parsing them, and
% generating a structured array containing the run parameters. These
% are then written to a .star file. 
%
% For ease of use, inputs are all set as optional parameters, which allows
% for arbitrarily ordered name-value pairs. However, a number of parameters
% are not optional, and this will be checked.
%
% WW 05-2019

% % % DEBUG
% varargin = {'param_name', 'vmap_param.star', 'rootdir', './', 'tempdir', 'none', 'commdir', 'none', 'rawdir', 'none', 'refdir', 'none', 'maskdir', 'none', 'listdir', 'none', 'subtomodir', 'none', 'vmap_mode', 'singleref', 'iteration', '2', 'binning', '4', 'motl_name', 'allmotl_A', 'ref_name', 'ref', 'vmap_name', 'var', 'mask_name', 'mask.mrc', 'wedgelist_name', 'wedgelist.star', 'subtomo_name', 'subtomo', 'symmetry', 'C1', 'fthresh', '300'};

%% Generate input parser

% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,~] = sg_get_vmap_input_arguments;
n_param = size(parser_param,2);

% Add parameters
for i = 1:n_param
    addParameter(parser,parser_param{1,i},[]);
end

% Parse arguments
parse(parser,varargin{:});
p = parser.Results;

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


%% Check vmap_mode

% Supported modes
vmap_modes = {'singleref','multiclass'};

% Check check
if ~any(strcmp(p.vmap_mode,vmap_modes))
    error('ACHTUNG!!!! Unsupported vmap_mode!!!');
end



%% Generate new parameter file
           
% Ordered output fields
output_fields = sg_get_ordered_vmap_input_fields;

% Add missing output fields
p.completed_p_vmap = false;
p.completed_f_vmap = false;

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
    old_param = sg_read_vmap_param(parser.Results.rootdir,parser.Results.param_name);
    
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

    
end



%% Write output

sg_write_vmap_param(new_param,parser.Results.rootdir,parser.Results.param_name);






