function new_motl = sg_motl_find_class_concensus(varargin)
%% sg_motl_find_class_concensus
% Take a number of input motivelists and find the entries that have the
% same class in each motivelist. 
%
% This function only works on single-entry motivelists.
%
% Output entries are parsed from the first motivelists.
%
% WW 12-2019

%% Load motivelists


% Check number of input motivelists
n_lists = 0;
for i = 1:numel(varargin)
    if iscell(varargin{i})
        n_lists = n_lists + numel(varargin{i});
    else
        n_lists = n_lists + 1;
    end
end


% Initialize motivelist cell
motl_cell = cell(n_lists,1);
n_motls = zeros(n_lists,1);


% Counter for motl_cell
c = 1;

% Load motivelists
for i = 1:numel(varargin)
    
    % Check for cell input
    if iscell(varargin{i})
        
        % Loop through cell contents
        for j = 1:numel(varargin{i})
            [motl_cell{c}, n_motls(c)] = read_convert_motl(varargin{i}{j});
            c = c+1;
        end
        
    else
        
        % Read single motivelist
        [motl_cell{c}, n_motls(c)] = read_convert_motl(varargin{i});
        c = c+1;
    end
    
end

% Check sizes
if ~all(n_motls==n_motls(1))
    error('ACHTUNG!!! Not all input motivelists are the same size!!!');
end

%% Determine concensus

% Class array
class_array = zeros(n_motls(1),n_lists,'int32');
for i = 1:n_lists
    class_array(:,i) = motl_cell{i}.class;
end

% Deterine concensus
c_idx = sum(class_array == repmat(class_array(:,1),1,n_lists),2)==n_lists;

% Determine highest scores
score_array = zeros(n_motls(1),n_lists);
for i = 1:n_lists
    score_array(:,i) = motl_cell{i}.score;
end
[~,max_idx] = max(score_array,[],2);

% New motivelist cell
new_motl_cell = cell(n_lists,1);
for i = 1:n_lists
    temp_idx = (max_idx == i) & c_idx;
    new_motl_cell{i} = sg_motl_parse_type2(motl_cell{i},temp_idx);
end

% Concatenate new motl
new_motl = sg_motl_concatenate(false,new_motl_cell);
new_motl = sg_sort_motl2(new_motl);



end


function [motl,n_entries] = read_convert_motl(input)
%% read_convert_motl
% Read motivelist or check and convert motivelist to type-2 and parse the
% relevent parameters.

% Read or convert motl
if ischar(input)
    motl = sg_motl_read2(input);
else
    r_type = sg_motl_check_read_type(input);
    switch r_type
        case 1
            motl = sg_motl_convert_type1_to_type2(input);
        case 2
            motl = input;
    end
end

% Parse parameters
n_entries = numel(motl.motl_idx);

end






