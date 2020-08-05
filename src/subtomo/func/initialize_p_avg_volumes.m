function v = initialize_p_avg_volumes(p,o,s,idx,mode,class)
%% initialize_p_avg_volumes
% Initialize a volume array for performing subtomogram averaging. 
%
% WW 05-2018

%% Initalize
disp([s.nn,'Initialzing parallel averaging volumes...']);

% Initialize struct
v = struct();

% Intialize names
v = parse_p_avg_vol_names(p,o,v,idx,mode,class);

% Name fields of v struct
name_fields = {'ref_names','wfilt_names','ps_names'};

 % Intialize volumes
for i = 1:numel(name_fields)
    
    if sg_check_param(v,name_fields{i})
        
        for j = 1:numel(v.(name_fields{i}))
            
            v.(v.(name_fields{i}){j}) = zeros(o.ss_boxsize,'single');
        end
    end
end   

