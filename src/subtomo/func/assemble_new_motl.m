function assemble_new_motl(p,o,s,idx)
%% assemble_new_motl
% Assemble a new motivelist following parallel alignment.
%
% WW 06-2019

%% Initialize
disp([s.nn,'Assembling new motivelist...']);

% Check for subset processing
subset = false;
if sg_check_param(p(idx),'subset')
    if p(idx).subset < 100
        subset = true;
    end
end

% Calculate parameters
if subset        
    % Calculate job parameters
    [~, ~,job_array] = job_start_end(o.n_rand_motls, o.n_cores, o.procnum);
else
    % Calculate job parameters
    [~, ~,job_array] = job_start_end(o.n_motls, o.n_cores, o.procnum);

end

% Size of motl
switch o.motl_type
    case {1,2}
        n_motls = o.n_motls;
        m = 1;
    case 3
        n_motls = o.n_motls*o.n_classes;
        m = o.n_classes;
end

% Get fields
motl_fields = sg_get_motl_fields();
n_fields = size(motl_fields,1);

% Initialize new motl
motl = sg_initialize_motl2(n_motls,motl_fields);

%% Fill new motl

% Fill motl
s_idx = 1;
for i = 1:o.n_cores
    
    % Parse name
    motl_name = [o.tempdir,'/splitmotl_',num2str(i),'.star'];
    
    % Size of split motl
    smotl_size = (job_array(i,1)*m);
    
    % Field indices
    e_idx = s_idx + smotl_size - 1;
    
    % Try to read
    t = 0; % Number of tries
    while t < s.n_tries
        try
            % Read motl
            splitmotl = sg_motl_read2([p(idx).rootdir,'/',motl_name],true);
            
            % Fill fields
            for j = 1:n_fields
                motl.(motl_fields{j,1})(s_idx:e_idx) = splitmotl.(motl_fields{j,1});
            end
            
            break
            
        catch
            warning([s.nn,'Failure reading ',motl_name,' on try ',num2str(t)]);
            t = t+1;
        end
        if t >= s.n_tries
            error([s.nn,'Failure reading ',motl_name]);
        end
    end
    

    % Increment counter
    s_idx = e_idx+1;
end

% Append unaligned particles
if subset
    % Determine motl indices of unaligned motls
    unali_motl = setdiff(o.motl_idx,o.rand_motl);
    % Determine list indices
    unali_idx = ismember(o.motl_idx,unali_motl);
    % Fill fields
    for j = 1:n_fields
        motl.(motl_fields{j,1})(s_idx:end) = o.allmotl.(motl_fields{j,1})(unali_idx);
    end
end
    
    

%% Write ouptut

% Write new motl
sg_motl_write2([p(idx).rootdir,'/',o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration+1),'.star'],motl);

disp([s.nn,'New motivelist assembled!!!']);



