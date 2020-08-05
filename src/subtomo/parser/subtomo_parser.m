function subtomo_parser(varargin)
%% subtomo_parser
% A function to take set of input arguments for performing subtomogram
% averaging with STOPGAP, parsing them, and generating a structured array
% containing the alignment parameters. These are then written to a .star 
% file. 
%
% For ease of use, inputs are all set as optional parameters, which allows
% for arbitrarily ordered name-value pairs. However, a number of parameters
% are not optional, and this will be checked.
%
% WW 06-2019

% % % % % DEBUG
% varargin = {'param_name', 'new_param.star', 'rootdir', '/fs/gpfs06/lv03/fileset01/pool/pool-plitzko/will_wan/empiar_10064/tm/all/', 'tempdir', 'none', 'commdir', 'none', 'rawdir', 'none', 'refdir', 'none', 'maskdir', 'none', 'listdir', 'none', 'fscdir', 'none', 'subtomodir', 'none', 'subtomo_mode', 'ali_multiclass', 'startidx', '8', 'iterations', '1', 'motl_name', 'allmotl_dclean01_kmeans', 'wedgelist_name', 'wedgelist.star', 'binning', '4', 'reflist_name', 'reflist.star', 'subtomo_name', 'subtomo', 'ccmask_name', 'ccmask.mrc', 'ali_reffilter_name', 'none', 'ali_particlefilter_name', 'none', 'avg_reffilter_name', 'none', 'avg_particlefilter_name', 'none', 'reffiltertype', 'none', 'particlefiltertype', 'none', 'ps_name', 'none', 'amp_name', 'none', 'specmask_name', 'none', 'search_mode', 'hc', 'search_type', 'cone', 'euler_axes', 'zxy', 'euler_1_incr', '1', 'euler_1_iter', '1', 'euler_2_incr', '1', 'euler_2_iter', '3', 'euler_3_incr', '1', 'euler_3_iter', '1', 'angincr', '2', 'angiter', '3', 'phi_angincr', '2', 'phi_angiter', '3', 'cone_search_type', 'coarse', 'scoring_fcn', 'laplacian_flcf', 'lp_rad', '25', 'lp_sigma', '3', 'hp_rad', '1', 'hp_sigma', '2', 'calc_exp', '1', 'calc_ctf', '1', 'cos_weight', '0', 'score_weight', '0.01', 'symmetry', 'C1', 'score_thresh', '0', 'subset', '100', 'avg_mode', 'partial', 'rot_mode', 'linear', 'fthresh', '300'};

%% Generate input parser

% Parameter types
job_types = {'ali','avg'};
job_subtypes = {'singleref','multiref','multiclass'};

% Initialize parser
parser = inputParser;

% Add parameter file name
addParameter(parser,'param_name',[]);

           
% Concatenate to parser paramters
[parser_param,param] = sg_get_subtomo_input_arguments;
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

 

%% Check subtomo mode
mode = strsplit(p.subtomo_mode,'_');
if ~any(strcmp(mode{1},job_types))
    error(['ACHTUNG!!! ',mode{1},' is not a supported type!!! Only "ali" and "avg" are allowed!!!']);
end
if ~any(strcmp(mode{2},job_subtypes))
    error(['ACHTUNG!!! ',mode{2},' is not a supported subtype!!! Only "singleref", "multiref", and "multiclass" are allowed!!!']);
end


%% Check alignment parameters

% Required parameters for all alignments
ali_req = {'iterations','lp_rad', 'hp_rad'};

switch mode{1}
    % Enforce requirements
    case 'ali'
        for i = 1:numel(ali_req)
            if isempty(p.(ali_req{i})) 
                error(['ACHTUNG!!! ',ali_req{i},' is required!!!']);
            end
        end
    % Clear unnecessary requirements    
    otherwise
        for i = 1:numel(ali_req)
            p.(ali_req{i}) = [];
        end
        p.hp_sigma = [];
        p.lp_sigma = [];
        
end





%% Check external filter parameters

% Supported filter types
filter_types = {'subtomo','tomo','none'};

% For averaging, clear alignment filters
if strcmp(mode(1),'avg')
    p.ali_particlefilter_name = [];
    p.ali_reffilter_name = [];
    
else
    
    % Reference filter
    rfilt_check = ~sg_check_empty_field(p.ali_reffilter_name) || ~sg_check_empty_field(p.avg_reffilter_name);
    if rfilt_check
        if sg_check_empty_field(p.reffiltertype)
            error('ACHTUNG!!! reffiltertype required if reference filters are set!!!');        
        elseif ~any(strcmp(p.reffiltertype,filter_types))
            error('ACHTUNG!!! reffilter types must be "subtomo" or "tomo"!!!');
        end
    end
    
end
      

% Particle filter
pfilt_check = ~sg_check_empty_field(p.ali_particlefilter_name) || ~sg_check_empty_field(p.avg_particlefilter_name);
if  pfilt_check
    if sg_check_empty_field(p.particlefiltertype)
        error('ACHTUNG!!! particlefiltertype required if particle filters are set!!!');        
    elseif ~any(strcmp(p.particlefiltertype,filter_types))
        error('ACHTUNG!!! particlefilter types must be "subtomo" or "tomo"!!!');
    end
end




%% Spectral analysis

% Check that psmask is given
if sg_check_param(p,'ps_name') || sg_check_param(p,'amp_name')

    if isempty(p.specmask_name) || strcmp(p.specmask_name,'none')
        error('ACHTUNG!!! When calculating powerspectra or amplitude spectra, "specmaskname" must be set!!!');
    end
end
    

%% Check scoring function 

if strcmp(mode(1),'ali')

    % Check for valid scoring function
    if ~isempty(p.scoring_fcn)
        scoring_match = strcmp(p.scoring_fcn,{'flcf','pearson'});
        if ~any(scoring_match)
            error(['ACHTUNG!!!! ',p.scoring_fcn,' is an unsupported scoring function!!!']);
        end
        
        % Check CC mask
        if any(strcmp(p.scoring_fcn,'pearson'))
            p.ccmaskanme = [];
        else
            if sg_check_empty_field(p.ccmask_name)
                error(['ACHTUNG!!! ccmask_name is required for scoring function ',p.scoring_fcn,'!!!']);
            end
        end
    end       
    
    
else
    p.apply_laplacian = [];
    p.scoring_fcn = [];
    p.ccmask_name = [];
end


%% Check alignment search parameters
search_modes = {'hc','shc','ga','sga'};

if strcmp(mode(1),'ali')
    
    % Check search mode
    if ~sg_check_param(p,'search_mode')
        p.search_mode = 'hc';
    else
        if ~any(strcmp(p.search_mode,search_modes))
            error('ACHTUNG!!! Unsuppored search mode!!!');
        end
    end
    
    % Parse search type
    if sg_check_param(p,'search_type')
        search_type = p.search_type;
    else
        search_type = 'cone';
    end
    
    % Generate parameters
    switch search_type    

        case 'cone'
            % Clear Euler parameters
            for i = 1:size(param.euler,2)
                p.(param.euler{1,i}) = [];
            end
            % Check cone search parameters
            for i = 1:4
                if isempty(p.(param.cone{1,i}))
                    error(['ACHTUNG!!!! ',param.cone{1,i},' missing!!! For a cone search, provide "angincr, angiter, phi_angincr, and phi_angiter"!!!']);
                end
            end
            
            if isempty(p.cone_search_type)
                p.cone_search_type = 'coarse';
            elseif ~any(strcmp(p.cone_search_type,{'coarse','complete'}))
                error('ACHTUNG!!! Only "coarse" or "complete" cone_search_types supported!!!');
            end

        case 'euler'
            % Clear Cone parameters
            for i = 1:size(param.cone,2)
                p.(param.cone{1,i}) = [];
            end
            % Set Euler search parameters
            if numel(p.euler_axes) ~= 3
                error('ACHTUNG!!! euler_axes must have 3 characters!!!');
            end
            % Check Euler arguments
            for i = 2:7
                if isempty(p.(param.euler{1,i}))
                    error(['ACHTUNG!!!! ',param.euler{1,i},' missing!!! For an Euler search, provide all "euler_?_incr/iter"!!!']);
                end
            end
            

        otherwise
            error('ACHTUNG!!! Unsupported search type!!! Only "cone" and "euler" supported!!!');
    end
else
    
    % Clear search parameters
    p.search_mode = [];
    p.search_type = [];
    for i = 1:size(param.euler,2)
        p.(param.euler{1,i}) = [];
    end
    for i = 1:size(param.cone,2)
        p.(param.cone{1,i}) = [];
    end
end




%% Check symmetry

if sg_check_param(p,'symmetry')
    
    % Symmetry IDs
    sym = struct;
    sym.c = 'Cyclic';
    sym.d = 'Dihedral';
    sym.o = 'Octohedral';
    sym.i = 'Icosahedral';
    temp_sym = lower(p.symmetry(1));
    switch temp_sym
        
        case {'c','d'}
            if numel(p.symmetry) > 1
                if ~sg_is_numeric(p.symmetry(2:end))
                    error(['ACHTUNG!!! Invalid symmetry operator!!! ',sym.(temp_sym),' requires a number afterwards...']);
                end
            else
                error(['ACHTUNG!!! Invalid symmetry operator!!! ',sym.(temp_sym),' requires a number afterwards...']);
            end
            
        case {'o','i'}
            if numel(p.symmetry) > 1
                error(['ACHTUNG!!! Invalid symmetry operator!!! ',sym.(temp_sym),' must have no number afterwards...']);
            end
            
        otherwise
            error('ACHTUNG!!! Unsupported symmetry operator!!! Only C ,D, O, and I allowed!!!');
    end
    
end



%% Check subset options

% Check subset ragne
if sg_check_param(p,'subset')
    if (p.subset <= 0) || (p.subset > 100)
        error('ACHTUNG!!! "subset" must be greater than 0 and less than 100!!!');
    end
elseif sg_check_param(p,'avg_mode')
    % No subset parameter, so average mode is by default full
    p.avg_mode = 'full';
end

% Check avg_mode
if sg_check_param(p,'avg_mode')
    if ~any(strcmp(p.avg_mode,{'full','partial'}))
        error('ACHTUNG!!! Only acceptable "avg_mode" settings are "full" and "partial"!!!');
    end
    if sg_check_param(p,'subset')
        if p.subset == 100
            p.avg_mode = 'full';
        end
    end
end

%% Check rotation mode

% Check rotation mode
if sg_check_param(p,'rot_mode')
    if ~any(strcmp(p.rot_mode,{'linear','cubic'}))
        error('ACHTUNG!!! Unsupported rotation mode!!! Only "linear" and "cubic" supported!!!');
    end
end

%% Check reflist

% Check for list
[~,~,ext] = fileparts(p.ref_name);

% If not a list
switch ext
    
    case '.star'
        
        % Clear non-required fields
        p.mask_name = [];
        p.symmetry = [];
        
    case ''

        % Check for mask
        if ~sg_check_param(p,'mask_name')
            error('ACHTUNG!!! For reference name input, an alignment mask is required!!!')
        end

        % Check for symmetry
        if ~sg_check_param(p,'symmetry')
            error('ACHTUNG!!!  For reference name input, symmetry is required!!!')
        end
        
    otherwise
        
        % Invalid input
        error('ACHTUNG!!! ref_name must either be a reference root name or a .star reference list!!!')    
    
end



%% Generate new parameter file
           
% Ordered output fields
output_fields = sg_get_ordered_subtomo_input_fields;

% Add missing output fields
p.completed_ali = false;
p.completed_p_avg = false;
p.completed_f_avg = false;
p.iteration = 0;

% Intialize new parameter
new_param = struct();

% Fill fields in order
for i = 1:size(output_fields,1)
    if ~sg_check_empty_field(p.(output_fields{i,1}))
        new_param.(output_fields{i,1}) = p.(output_fields{i,1});
    end
end

% Generate entry for each iteration
if strcmp(mode{1},'ali')
    new_param = repmat(new_param,[p.iterations,1]);
    iterations = num2cell(p.startidx+(0:p.iterations-1));
    [new_param.iteration] = iterations{:};
else
    new_param.iteration = p.startidx;
end

% Generate temperature factors for simulated annealing
if sg_check_param(p,'temperature')
    if strcmp(mode{1},'ali')
        temps = num2cell(linspace(p.temperature,0,p.iterations+1));
        [new_param.temperature] = temps{1:end-1};
    else
        new_param = rmfield(new_param,'temperature');
    end
end


%% Append old param file

% Check for old paramfile and read if it exists
paramname = [parser.Results.rootdir,'/',parser.Results.param_name];
if exist(paramname,'file')        

    % Read old parameter file
    old_param = sg_read_subtomo_param(parser.Results.rootdir,parser.Results.param_name);
    
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

sg_write_subtomo_param(new_param,parser.Results.rootdir,parser.Results.param_name);
