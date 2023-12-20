function sg_motl_split_by_tomo(input_name,output_root,output_suffix)
%% sg_motl_split_by_tomo
% A function to split a motivelist by tomogram number. Output name will
% consist of [output_root]_[tomo_num]_[output_suffix].
%
% WW 11-2022


%% Check check

% Check for suffix
if nargin < 3
    output_suffix = '.star';    
    
end

% Check for extension
[~,~,ext] = fileparts(output_suffix);

% Append file extension
if isempty(ext)
    output_suffix = [output_suffix,'.star'];
end


%% Split motl

% Read motl
motl = sg_motl_read2(input_name);

% Parse tomo indices
tomos = unique(motl.tomo_num);
n_tomos = numel(tomos);


% Parse and write out tomos
for i = 1:n_tomos
    
    % Parse tomo
    tomo_idx = motl.tomo_num == tomos(i);
    temp_motl = sg_motl_parse_type2(motl,tomo_idx);
    
    % Write tomo
    split_name = [output_root,'_',num2str(tomos(i)),'_',output_suffix];
    sg_motl_write2(split_name,temp_motl);
        
end






