function o = initialize_motl_for_parallel_average(p,o,s,idx)
%% initialize_motl_for_parallel_average
% Read run settings and determine motls for parallel averaging.
%
% WW 08-2018

%% Check check

% Check averaging type
if sg_check_param(p(idx),'avg_mode');
    avg_mode = p(idx).avg_mode;
elseif sg_check_param(p(idx),'subset')
    if p(idx).subset < 100
        avg_mode = 'partial';
    else
        avg_mode = 'full';
    end
else
    avg_mode = 'full';
end



%% Determine motls for averaging
disp([s.nn,'Initializing motivelist for parallel averaging...']);

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

% Check for parallel averagig node
switch mode{1}
    case 'ali'
        o.n_cores_p_avg =  determine_n_p_avg_cores(o.n_motls,o.n_cores);
        o.p_avg_cores = round(linspace(1,o.n_cores,o.n_cores_p_avg));        
        o.p_avg_node = any(o.p_avg_cores==o.procnum);
        o.p_avg_procnum = find(o.p_avg_cores==o.procnum);
    case 'avg'
        o.p_avg_cores = 1:o.n_cores;
        o.n_cores_p_avg = o.n_cores;
        o.p_avg_node = true;
        o.p_avg_procnum = o.procnum;
end

% Check for partial average
o.partavg = false;
if sg_check_param(p(idx),'subset')
    if (p(idx).subset < 100) && strcmp(avg_mode,'partial')
        o.partavg = true;
    end
end
        
        




% Check for final averaging node
switch mode{2}
    
    case 'singleref'
        
        o.f_avg_node = o.procnum == 1;
        o.f_avg_class = 1;
        o.n_f_avg_class = 1;
        o.n_cores_f_avg = 1;
        
        
    otherwise
        % Evenly split classes amongst cores
        f_avg_cores = repmat(1:o.n_cores,[ceil(o.n_classes/o.n_cores),1]);
        f_avg_cores = f_avg_cores(1:o.n_classes);
        
        % Assign final averaging node
        o.f_avg_node = any(f_avg_cores == o.procnum);
        
        % Assign classes to node
        if o.f_avg_node
            o.f_avg_class = o.classes((f_avg_cores == o.procnum));
            o.n_f_avg_class = numel(o.f_avg_class);
        end
        
        % Number of final averaging cores
        if o.n_classes > o.n_cores
            o.n_cores_f_avg = o.n_cores;
        else
            o.n_cores_f_avg = o.n_classes;
        end
end
    

if o.p_avg_node || o.f_avg_node

    % Calculate job parameters
    if o.partavg
        [o.p_avg_start, o.p_avg_end, o.job_array] = job_start_end(o.n_rand_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    else
        [o.p_avg_start, o.p_avg_end, o.job_array] = job_start_end(o.n_motls, o.n_cores_p_avg, o.p_avg_procnum);
        o.n_p_avg = o.p_avg_end - o.p_avg_start + 1;
    end

end 
  
  
  
  
  
