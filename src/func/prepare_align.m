function o = prepare_align(p,o,idx)
%% prepare_align
% A function to load in an allmotl and generating job parameters. The
% parameters are taken from the 'p' struct at the given index (idx), an
% loaded to the 'o' struct. The procnum is used to generate alginment job 
% parameters. Averaging job parameters are determined during averaging.
%
% v1: WW 11-2017
% v2: WW 01-2018 Some small bugfixes.
%
% WW 01-2018

%% Initialize
% Get node name
global nn


%% Generate parameters for all alignment modes

% Number of iclass
n_iclass = numel(p(idx).iclass);

% Start and end motls for job
[start_motl, end_motl] = job_start_end(o.n_motls, p(idx).n_cores_ali, o.procnum);
j_idx = false(1,o.n_motls);
j_idx(start_motl:end_motl) = true;
o.ali_motl_job_idx = j_idx;
    



%% Generate specific alignment job parameters
switch p(idx).subtomo_mode


    case 'ali_singleref'
        disp([nn,'Initializing single-reference subtomogram alignment...']);

        % Check allmotl
        if size(o.allmotl,3) > 1
            error([nn,'Achtung!!! Multireference motl given for single-reference alignment!!1!'])
        end

        % Get included classes
        if p(idx).iclass == 0
            motl_idx = true(1,o.n_motls);
        else

            motl_idx = logical(sum(repmat(abs(o.allmotl(20,:)),[n_iclass,1]) == repmat(p(idx).iclass',[1,o.n_motls]),1));
        end
        
        % Motls that meet iclass restrictions
        o.ali_motl_idx = motl_idx & j_idx;
        
        % Number of classes
        o.n_classes = 1;



    case 'ali_multiclass'
        disp([nn,'Initializing multi-class subtomogram alignment...']);

        % Check allmotl
        if size(o.allmotl,3) > 1
            error([nn,'Achtung!!! Multireference motl given for multi-class alignment!!1!'])
        end

        % Check included classes
        if p(idx).iclass == 0
            o.classes = unique(abs(o.allmotl(20,:)));
        else
            o.classes = intersect(unique(abs(o.allmotl(20,:))),p(idx).iclass);
        end
        o.n_classes = numel(o.classes);

        % Generate indices
        motl_idx = repmat(abs(o.allmotl(20,:)),[o.n_classes,1]) == repmat(o.classes',[1,o.n_motls]);
        o.ali_motl_idx = motl_idx & repmat(j_idx,[o.n_classes,1]);



    case 'ali_multiref'
        disp([nn,'Initializing multi-reference subtomogram alignment...']);

        % Check allmotl
        if ~size(o.allmotl,3) > 1
            warning([nn,'Achtung!!! Allmotl has only 1 class; !!1!'])
        end

        % Check included classes
        if p(idx).iclass == 0
            o.classes = squeeze(abs(o.allmotl(20,1,:)));
            o.ali_iclass_idx = true(size(o.classes));            
        else
            [o.classes, o.ali_iclass_idx] = intersect(abs(o.allmotl(20,1,:)),p(idx).iclass);
        end
        o.n_classes = numel(o.classes);
        
        % Store indices
        o.ali_motl_idx = repmat(j_idx,[o.n_classes,1]);


end
  
end 
    
