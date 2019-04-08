function stopgap_subtomo(rootdir,paramfilename, procnum)
%% stopgap_manager
% A function to performing subtomogram averaging with TOM/AV3. The
% subtomo_manager manages the three subtomogram averaging processes:
% subtomogram alignmnet, parallel averaging, and final averaging. By using
% a manager, the nodes can be held until the entire averaging process is
% complete.
%
% This function also allows for three types of aligment modes: singleref,
% multiref, and multiclass:
% In singleref, there is a single reference, the allmotl file is is a 2D 
% array, but can contain an arbitrary number of classes. The classes to be 
% aligned are defined by the iclass parameters; iclass of 0 means all
% classes will be aligned.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to add on-the-fly slice wedgemasks calculation
% along with CTF and expsoure reference filtering. Also added was angular
% search using arbitrary Euler triplets. 
%
% WW 01-2018

% % % % % % DEBUG
% rootdir = '/fs/pool/pool-EMpub/4Will/from_anna/Filter/';
% paramfilename = 'param.star';
% procnum = '1';

%% Evaluate numeric inputs
if (ischar(procnum)); procnum=eval(procnum); end

%% Initialize
% Initialize node name
global nn
nn = ['Node',num2str(procnum),': '];
disp([nn,'Initializing...']);
avg_modes = {'avg_singleref', 'avg_multiclass', 'avg_multiref'};

% Wait time
wait_time = 5;


% Initialize struct array to hold objects
o = struct();
o.procnum = procnum;

% Read parameter file
[p, idx] = update_param(rootdir,paramfilename);



% Check if node is an averaging node
averaging_nodes = round((p(idx).total_cores/p(idx).n_cores_aver)*(1:p(idx).n_cores_aver));  % Distribute averaging over nodes numbers
o.procnum_aver = find(averaging_nodes==o.procnum, 1, 'first');     % Processor number for averaging
if isempty(o.procnum_aver)
    o.procnum_aver = 0;   % procnum_aver==0 is a non-averaging node
end
    

%% Fill 'o' struct

% Basic files to read at each iteration {param field; variable name}
basic_files = {'maskname', 'ccmaskname'; 'mask', 'ccmask'};
skipcase = {'none'};  % If param field is a member of skipcase, skip reading

% Load wedgelist
o = refresh_wedgelist(p, o, idx, 'init');

% Read in allmotl
o = get_allmotl(p,o,idx);

% Get box size
o = get_boxsize(p,o,idx);




%% Begin big loop
run = true;
while run
    disp([nn,'Starting subtomogram averaging iteration ',num2str(p(idx).iteration)]);
    
    
    
    % Subtomogram alignment!
    if ~p(idx).completed_ali && ~any(strcmp(p(idx).subtomo_mode,avg_modes))
        
        % Refresh files        
        o = refresh_emfile(p,o,idx,basic_files,'init',skipcase);
        
        % Calculate angle list
        o = get_angles(p,o,idx,'init');
        
        % Generate bandpass filter
        o = generate_bpf(p,o,idx,'init');
        
        % Refresh alignment filter
        o = refresh_alignment_filter(p, o, idx, 'init');

        % Prepare alignment parameters
        o = prepare_align(p,o,idx);
        
        % Read in reference    
        o = get_references(p,o,idx);
        
        % Perform subtomogram alignment
        stopgap_align_subtomos(p,o,idx);

        % Wait for completion of alignment step
        wait_for_it([p(idx).rootdir,'/',p(idx).completedir],'stopgap_ali',wait_time);
    end

    
    
    % Parallel weighted average 
    if ~p(idx).completed_p_aver        
         
        % Compute parallel average
        if o.procnum_aver ~= 0
            stopgap_parallel_average(p,o,idx);
        end
        
        % Wait for completion
        wait_for_it([p(idx).rootdir,'/',p(idx).completedir],'stopgap_p_aver',wait_time);
    end
    

    % Final concatenation
    if ~p(idx).completed_f_aver
        
        % Compute final average
        if procnum <= o.n_classes
            stopgap_final_average(p,o,idx);
        end
        
        % Wait for completion
        wait_for_it([p(idx).rootdir,'/',p(idx).completedir],'stopgap_f_aver',wait_time);
    end
    
    
    
    % Update param file
    [p,idx] = update_param(rootdir, paramfilename, p(idx).iteration, p(idx).subtomo_mode, 'none');
    idx = idx+1;    % Increment index
    
    % Check for end of run and refresh parameters if necessary
    if idx > size(p,1)
        disp([nn,'End of param file reached... ']);
        % End of param file reached; time to die
        run = false;
    else
        % Refresh static files        
        o = refresh_wedgelist(p, o, idx, 'init');
        
        % Refresh alignment parameters
        if ~any(strcmp(p(idx).subtomo_mode,avg_modes))             
            o = refresh_emfile(p,o,idx,basic_files,'refresh',skipcase);
            o = get_angles(p,o,idx,'refresh');
            o = generate_bpf(p,o,idx,'refresh');
            o = refresh_alignment_filter(p, o, idx, 'refresh');
        end
        % Read new allmotl
        o = get_allmotl(p,o,idx);
        % Get box size
        o = get_boxsize(p,o,idx);
    end
    
    
    
end % End while
    
disp([nn,'Subtomogram averaging finished!!!']);

end 




