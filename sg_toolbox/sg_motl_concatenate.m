function new_motl = sg_motl_concatenate(renumber_motl_idx,varargin)
%% sg_motl_concatenate
% Concatenate a set of motivelists. The renumber_motl_idx parameter sets
% whether or not to renumber the motl_idx parameter. If enabled,
% motivelists are renumbered starting at 1. 
%
% Input motivelists are supplied as varargin. If strings are passed, they
% are assumed to be filenames, and the motivelist are read in. Multiple 
% motivelists or names can also be supplied as cell arrays or any
% combinations.
%
% WW 12-2019

%% Check check

% Check input
if isempty(varargin)
    error('ACHTUNG!!! No input motivelists!!!');
end


% Check number of input motivelists
n_motl = 0;
for i = 1:numel(varargin)
    if iscell(varargin{i})
        n_motl = n_motl + numel(varargin{i});
    else
        n_motl = n_motl + 1;
    end
end

% Initialize cell to hold motivelists
motl_cell = cell(n_motl,1);
motl_types = zeros(n_motl,1);
classes = cell(n_motl,1);
n_classes = zeros(n_motl,1);
n_entries = zeros(n_motl,1);
n_idx = zeros(n_motl,1);


%% Read motivelists

% Counter for motl_cell
c = 1;

% Loop through inputs
for i = 1:numel(varargin)
    
    % Check for cell input
    if iscell(varargin{i})
        
        % Loop through cell contents
        for j = 1:numel(varargin{i})
            [motl_cell{c}, motl_types(c), classes{c}, n_classes(c), n_entries(c), n_idx(c)] = sg_read_convert_motl(varargin{i}{j});
            c = c+1;
        end
        
    else
        
        % Read single motivelist
        [motl_cell{c}, motl_types(c), classes{c}, n_classes(c), n_entries(c), n_idx(c)] = sg_read_convert_motl(varargin{i});
        c = c+1;
    end
    
end

% Check types
if (any(motl_types == 3)) && (~all(motl_types == 3))
    error('ACHTUNG!!! You are attempting combining multi-entry and non-multi-entry motivelists!!!')
elseif (any(motl_types == 1)) && (any(motl_types == 2))
    warning('ACHTUNG!!! You are combining single-ref and non-multi-class motivelists!!!')
end


% Multi-ref checks
if all(motl_types == 3)
    
    % Check number of classes
    if ~all(n_classes~=n_classes(1))
        error('ACHTUNG!!! Inconsistent number of classes between multi-entry motivelists!!!')
    end
    
    % Check classes
    all_classes = cat(1,classes{:});
    for i = 1:size(all_classes,2)
        if ~all(all_classes(:,1) == all_classes(1,i))
            error('ACHTUNG!!! Inconsistent classes between multi-entry motivelists!!!')
        end
    end
end




%% Combine motivelists

% Initialize new motivelist
new_motl = sg_initialize_motl2(sum(n_entries));

% Read motivelist fields
motl_fields = sg_get_motl_fields;
n_fields = size(motl_fields,1);    

% Starting entry index
s = 1;

% Starting motl index
if renumber_motl_idx
    s_idx = 1;
end

% Loop through motivelist
for i = 1:n_motl
    
    % Ending motl index
    e = sum(n_entries(1:i));

    % Check for renumbering
    if renumber_motl_idx
        
        % Ending index
        e_idx = sum(n_idx(1:i));
        
        % Number of entries
        new_idx = int32(s_idx:e_idx);
        
        % Map old entires onto new
        [~,~,old_idx] = unique(motl_cell{i}.motl_idx);
        
        % Store new indices
        new_motl.motl_idx(s:e) = new_idx(old_idx);
        
        % Increment coutner
        s_idx = e_idx + 1;
        
    else        
        new_motl.motl_idx(s:e) = motl_cell{i}.motl_idx;
    end
    
    % Copy remaining feilds
    for j = 2:n_fields
        new_motl.(motl_fields{j,1})(s:e) = motl_cell{i}.(motl_fields{j,1});
    end
    
    % Increment counter
    s = e+1;
    
end

end

    



