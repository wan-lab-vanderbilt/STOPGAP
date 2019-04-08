%% load_allmotl

function o = load_allmotl(p,o,idx)
% A function to load in an allmotl and generating job parameters. The
% parameters are taken from the 'p' struct at the given index (idx), an
% loaded to the 'o' struct. The procnum is used to generate job parameters.
%
% WW 11-2017

 % Get node name
global nn


% Read in allmotl
disp([nn,'Reading allmotl and generating job parameters']);
aname = [p(idx).allmotlname,'_',num2str(p(idx).iteration),'.em'];
try
    o.allmotl = emread([rootdir,'/',aname]);
catch
    error([nn,'Achtung! Allmotl read error!!!']);
end
o.n_motls = size(o.allmotl,2);

% Generate parameters for all alignment modes
if ~strcmp(p(idx).subtomo_mode,'average')
    % Number of iclass
    n_iclass = numel(p(idx).iclass);

    % Start and end motls for job
    [start_motl, end_motl] = will_job_start_end(o.n_motls, p(idx).n_cores_ali, o.procnum);
    j_idx = false(1,n_motls);
    j_idx(start_motl:end_motl) = true;
    
end

% Generate specific alignment job parameters
switch p(idx).subtomo_mode


    case 'singleref'
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
        o.ali_motl_idx = motl_idx & j_idx;



    case 'multiclass'
        disp([nn,'Initializing multi-class subtomogram alignment...']);

        % Check allmotl
        if size(o.allmotl,3) > 1
            error([nn,'Achtung!!! Multireference motl given for multi-class alignment!!1!'])
        end

        % Check included classes
        if p(idx).iclass == 0
            o.classes = unique(o.allmotl(20,:));
        else
            o.classes = intersect(unique(o.allmotl(20,:)),p(idx).iclass);
        end
        o.n_classes = numel(o.classes);

        % Generate indices
        motl_idx = permute(repmat(abs(o.allmotl(20,:)),[o.n_classes,1]) == repmat(o.classes',[1,o.n_motls]),[3,2,1]);
        o.ali_motl_idx = motl_idx & repmat(j_idx,[o.n_classes,1]);



    case 'multiref'
        disp([nn,'Initializing multi-reference subtomogram alignment...']);

        % Check allmotl
        if ~size(o.allmotl,3) > 1
            warning([nn,'Achtung!!! Allmotl has only 1 class; !!1!'])
        end

        % Check included classes
        if iclass == 0
            o.classes = permute(o.allmotl(20,1,:),[2,3,1]);
        else
            [o.classes, o.ali_class_idx] = intersect(o.allmotl(20,1,:),p(idx).iclass);
        end
        o.n_classes = numel(o.classes);

        % Generate indices
        o.ali_motl_idx = j_idx;

end


if o.procnum_aver ~= 0
    % Start and end motls for averaging job
    [start_motl, end_motl] = will_job_start_end(o.n_motls, p(idx).n_cores_aver, o.procnum_aver);
    aver_motl_idx = false(1,n_motls);
    aver_motl_idx(start_motl:end_motl) = true;
    o.aver_motl_idx = aver_motl_idx;
end
  
end 
    
