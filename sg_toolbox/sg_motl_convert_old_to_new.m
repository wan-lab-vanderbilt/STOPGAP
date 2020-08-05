function sg_motl_convert_old_to_new(motl_name,new_motl_name)
%% sg_motl_convert_old_to_new
% Converts old STOPGAP motivelists (i.e. 0.6.2 and older) to newer 0.7
% format. The difference is the addition of the 'motl_idx' filed. 
%
% This script attempts to add this extra field. 
%
% WW 06-2019

%% Check check
if nargin == 1
    overwrite = true;
else
    overwrite = false;
end

%% Convert!!!

% Read old format
motl = sg_old_motl_read(motl_name);

% Sort motl
sort_array = cat(2,[motl.tomo_num]',[motl.subtomo_num]',[motl.class]');
[~,sort_idx] = sortrows(sort_array,[1,2,3]);
motl = motl(sort_idx);

% Check type
motl_type = sg_motl_check_type(motl,1);

% Generate motl index
switch motl_type    
    case {1,2}        
        motl_idx = 1:numel(motl);
    case 3
        n_subtomo = numel(unique(sort_array(:,2)));
        n_class = numel(unique(sort_array(:,3)));
        motl_idx = reshape(repmat(1:n_subtomo,n_class,1),[],1);
end
        
% Add field
new_motl = sg_motl_fill_field(motl,'motl_idx',motl_idx);

% Write output
if overwrite
    system(['cp ',motl_name,' ' ,motl_name,'~']);
    sg_motl_write(motl_name,new_motl);
else
    sg_motl_write(new_motl_name,new_motl);
end


