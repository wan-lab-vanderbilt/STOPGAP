function tm_parser(varargin)
%% stopgap_tm_parser
% Parseinputs to generate a parameter file for STOPGAP template matching.
%
% WW 01-2019

%%%% DEBUG
% varargin = {'param_name', 'tm_param.star', 'rootdir', '/fs/pool/pool-plitzko/will_wan/jonathan/sg_tm_0.3/', 'tempdir', 'none', 'commdir', 'none', 'tmpldir', 'none', 'maskdir', 'none', 'mapdir', 'none', 'listdir', 'none', 'wedgelist_name', 'wedgelist.star', 'tomolist_name', 'tomolist2.txt', 'tlist_name', 'tlist_groel.star', 'smap_name', 'smap_flcf_groel_6deg_40A_c7', 'omap_name', 'omap_flcf_groel_6deg_40A_c7', 'tmap_name', 'tmap_flcf_groel_6deg_40A_c7', 'lp_rad', '11', 'lp_sigma', '3', 'hp_rad', '1', 'hp_sigma', '2', 'binning', '4', 'noise_corr', '1'};

%% Generate input parser
% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,~] = sg_get_tm_parameter_arguments;
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


%% Read tomolist

% Parse listdir
if sg_check_param(p,'listdir')
    listdir = p.listdir;
else
    listdir = 'lists/';
end

% Read tomolist
fid = fopen([p.rootdir,listdir,p.tomolist_name],'r');
tomolist = textscan(fid,'%s %s');
fclose(fid);
n_tomos = size(tomolist{1},1);
tomo_num = num2cell(zeros(n_tomos,1));

% Check for numeric filename
for i = 1:n_tomos
    % Parse name
    [~, name, ~] = fileparts(tomolist{1}{i});
    % Check for integer
    if all(ismember(name,'0123456789'))
        tomo_num{i} = str2double(name);
    else
        error(['ACHTUNG!!! Tomogram names must be integers to match wedgelist tomo_num fields!!! See tomolist line ',num2str(i),'!!!']);        
    end
end


%% Check scoring function
% 
% % Supported scoring functions
% s_sfcn = {'flcf', 'scf'};
% if sg_check_param(p,'scoring_fcn')
%     if ~any(strcmp(p.scoring_fcn,s_sfcn))
%         error('ACTHUNG!!! Unsuppored input scoring function!!1!');
%     end
% end


%% Generate new parameter file
           
% Ordered output fields
output_fields = sg_get_ordered_tm_input_fields;

% Add missing output fields
p.completed_p_tm = false;
p.completed_f_tm = false;
p.tomo_name = 'none';
p.tomo_num = 0;
p.tomo_mask_name = 'none';

% Intialize new parameter
new_param = struct();

% Fill fields in order
for i = 1:size(output_fields,1)
    if ~sg_check_empty_field(p.(output_fields{i,1}))
        new_param.(output_fields{i,1}) = p.(output_fields{i,1});
    end
end

% Generate entry for each tomogram
new_param = repmat(new_param,[n_tomos,1]);
[new_param.tomo_name] = tomolist{1}{:};
[new_param.tomo_num] = tomo_num{:};
if ~isempty([tomolist{2}{:}])
    [new_param.tomo_mask_name] = tomolist{2}{:};
end



%% Append old param file

% Check for old paramfile and read if it exists
paramname = [parser.Results.rootdir,'/',parser.Results.param_name];
if exist(paramname,'file')        

    % Read old parameter file
    old_param = sg_read_tm_param(parser.Results.rootdir,parser.Results.param_name);
    
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

sg_write_tm_param(new_param,parser.Results.rootdir,parser.Results.param_name);

