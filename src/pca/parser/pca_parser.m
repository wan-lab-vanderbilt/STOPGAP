function pca_parser(varargin)
%% pca_parser
% A function to take set of input arguments and generate a parameter file
% for principle component analysis. PCA consists of several independent
% steps, so each entry in the param file is generated for one step.
%
% WW 05-2019

% % % % % DEBUG
% varargin = {'param_name', 'pca_param.txt', 'rootdir', '/fs/pool/pool-plitzko/will_wan/HIV_testset/subtomo/flo_align/speed_test/bin1/shc_vmap/', 'tempdir', 'none', 'commdir', 'none', 'rawdir', 'none', 'refdir', 'none', 'maskdir', 'none', 'listdir', 'none', 'subtomodir', 'none', 'rvoldir', 'none', 'pcadir', 'none', 'iteration', '1', 'motl_name', 'allmotl', 'wedgelist_name', 'wedgelist', 'binning', '4', 'ref_name', 'ref', 'mask_name', 'mask', 'subtomo_name', 'subtomo', 'rvol_type', 'vol', 'filtlist_name', 'filter_list.star', 'ccmat_name', 'ccmatrix', 'n_eigs', '5', 'eigenvol_name', 'eigenvol', 'eigencoeff_name', 'eigencoeff', 'eigenval_name', 'eigenval', 'symmetry', 'c1', 'fthresh', '300', 'write_raw', '0'};

%% Generate input parser

% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,~] = sg_get_pca_input_arguments;
n_param = size(parser_param,2);

% Add parameters
for i = 1:n_param
    addParameter(parser,parser_param{1,i},[]);
end

% Parse arguments
parse(parser,varargin{:});
p = parser.Results;

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


%% Check scoring function
% scoring_fcn = {'pearson'};
% if isfield(p,'scoring_fcn')
%     if ~any(strcmpi(p.scoring_fcn,scoring_fcn))
%         error('ACHTUNG!!! Unsupported scoring function!!! Only "pearson" is supported!!!');
%     end
% end

%% Check tasks

tasks = sg_get_pca_tasks();
if ~any(strcmp(p.pca_task,tasks))
    error(['ACHTUNG!!! Unsupported PCA task: ',p.pca_task,'!!!']);
end


%% Write output

% Get ordered output
output_fields = sg_get_ordered_pca_input_fields();

% Add missing output fields
p.completed = false;

% Fill fields in order
new_param = struct();
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
    old_param = sg_read_pca_param(parser.Results.rootdir,parser.Results.param_name);
    
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

sg_write_pca_param(new_param,parser.Results.rootdir,parser.Results.param_name);



