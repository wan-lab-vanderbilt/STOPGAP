function s = parse_stopgap_inputs(varargin)
%% parse_stopgap_inputs
% Parse inputs for a STOPGAP job.
%
% WW 03-2021


% % % % % DEBUG
% varargin = {'rootdir', '/dors/wan_lab/home/wanw/research/HIV_testset/subtomo/vandy/full/bin8_test/', 'paramfilename', 'params/subtomo_param.star', 'procnum', '1', 'n_cores', '128', 'job_id', '123123', 'node_name', 'cn100', 'node_id', '1', 'n_nodes', '2', 'local_id', '1'};



%% Generate input parser

% Initialize parser
parser = inputParser;

% Concatenate to parser paramters
[parser_param,~] = sg_get_stopgap_input_arguments;
n_param = size(parser_param,2);


% Add parameters
for i = 1:n_param
    addParameter(parser,parser_param{1,i},[]);
end

% Parse arguments
parse(parser,varargin{:});
p = parser.Results;

% Check root directory name
p.rootdir = sg_check_dir_slash(p.rootdir);



%% Check required parameters

% Check parser_param
for i = 1:n_param
    if isempty(p.(parser_param{1,i})) && strcmp(parser_param{3,i},'req')
        error(['ACHTUNG!!! ',parser_param{1,i},' is required!!!']);
    end
end

% Evalulate non-string inputs
s = parser_evaluate(p,parser_param);

 

