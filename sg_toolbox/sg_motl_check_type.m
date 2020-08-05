function motl_type = sg_motl_check_type(motl,read_format)
%% sg_motl_check_type
% Check motivelist to determine type and consistency. The function will
% return warnings for inconsistent types.
%
% Types are:
% 1 - Singleref         (1 class for all subtomograms)
% 2 - Multiclass        (multiple classes, 1 entry for each subtomogram)
% 3 - Multientry        (multiple classes, each subtomogram has an entry
%                        for each class)
%
% WW 06-2019


%% Check check

if ischar(motl)
    motl_name = motl;
    motl = sg_motl_read2(motl_name);
    read_format = 2;
end
    

if nargin == 1
    if numel([motl.subtomo_num]) > numel(motl)
        read_format = 2;
    else
        read_format = 1;
    end
end
    
%% Parse fields

% Parse numbers from motivelist
switch read_format
    case 1
        n_motls = numel(motl);
        subtomo_num = [motl.subtomo_num];
        class = [motl.class];
    case 2
        n_motls = numel(motl.subtomo_num);
        subtomo_num = motl.subtomo_num;
        class = motl.class;
end

% Unique subtomos
subtomos = unique(subtomo_num);
n_subtomos = numel(subtomos);

% Unique classes
classes = unique(class);
n_classes = numel(classes);

%% Determine type

% Initial check
if n_subtomos == n_motls
    if n_classes == 1
        motl_type = 1;
        return
    elseif n_classes > 1
        motl_type = 2;
        return
    end
end

% Singleref
if n_classes == 1
    motl_type = 1;
    warning('ACHTUNG!!! This singleref motivelist contains multiple entries for each subtomogram!!!');
    return
end


if ~mod(n_motls,(n_subtomos.*n_classes))    % Initial check for multientry
    
    % Concatenate subtomogram and class number
    sc_array = cat(2,subtomo_num(:),class(:));
    
    % Sort
    sort_sc_array = sortrows(sc_array,[1,2]);
    
    % Rows are class IDs, values are subtomo_num
    s_array = reshape(sort_sc_array(:,1),n_classes,[]);
    
    % Columns should contain identical numbers
    s_test = s_array == repmat(s_array(1,:),n_classes,1);
    
    % Return type
    if all(s_test(:))
        motl_type = 3;
        
        if (n_motls/(n_subtomos.*n_classes)) > 1
            error('ACHTUNG!!! This multientry motivelist contains multiple entries for each subtomogram!!!');
        end
        
    else
        motl_type = 2;
        warning('ACHTUNG!!! This multiclass motivelist contains multiple entries for each subtomogram!!!');
    end
    
else
    
    motl_type = 2;
    warning('ACHTUNG!!! This multiclass motivelist contains multiple entries for each subtomogram!!!');
end

    
    
    
    
    


        

        

        

        