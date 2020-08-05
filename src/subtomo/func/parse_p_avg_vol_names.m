function v = parse_p_avg_vol_names(p,o,v,idx,mode,class)
%% parse_p_avg_vol_names
% Parse volume names for parallel averaging depending on run parameters.
%
% WW 06-2019

%% Determine number of references

% Parse reference classes
reflist_classes = reshape([o.reflist.class],[],1);

% Number of references in reflist
n_ref = numel(o.reflist);

% Parse reference indices
switch mode{2}
    case 'singleref'
        if n_ref == 1
            ref_idx = 1;
        else
            ref_idx = reflist_classes == 1;
        end
        
    otherwise

        ref_idx = find(reflist_classes == class);
        
end

% Initialize reference name struct
v.ref_names = cell(2,1);

% Name extensions
ext = cell(2,1);
        
        
% All names
if sg_check_param(p(idx),'ps_name')
    all_names = cell(3,1);
else
    all_names = cell(2,1);
end

%% Generate reference names

for h = 1:2
    
    % Load based on mode
    switch mode{2}
        case 'singleref'
            
            % Extension
            ext{h} = ['_',char(64+h)];
            
            % Store reference name
            v.ref_names{h} = [o.reflist(ref_idx).ref_name,ext{h}];
            
        otherwise

            % Extension
            ext{h} = ['_',char(64+h),'_',num2str(class)];

            % Store reference name
            v.ref_names{h} = [o.reflist(ref_idx).ref_name,ext{h}];
                
            
    end
    
end

% Add to all names
all_names{1} = v.ref_names;

%% Generate weighting filter names

% Initialize cell
v.wfilt_names = cell(size(v.ref_names));

% Fill names
for i = 1:numel(ext)
    v.wfilt_names{i} = ['wfilt',ext{i}];
end

% Add to all names
all_names{2} = v.wfilt_names;


%% Check spectral filter

if sg_check_param(p(idx),'ps_name')
    
    % Initialize cell
    v.ps_names = cell(size(v.ref_names));

    % Fill names
    for i = 1:numel(ext)
        v.ps_names{i} = ['ps',ext{i}];
    end
    
    % Add to all names
    all_names{3} = v.ps_names;
    
end


%% Store all names

v.all_names = cat(1,all_names{:});






