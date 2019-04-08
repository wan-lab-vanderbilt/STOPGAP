function stopgap_cleanup(p,idx)
%% stopgap_cleanup
% A function to remove the temporary files generated during subtomogram
% alignment. 
%
% WW 11-2017

%% Initialize
ali_modes = {'ali_singleref', 'ali_multiclass', 'ali_multiref'};
avg_modes = {'avg_singleref', 'avg_multiclass', 'avg_multiref'};

% Check for existence of blank folder
blankdir = [p(idx).rootdir,'/blank/'];
if ~exist(blankdir,'dir')
    mkdir(blankdir);
end


%% Clean folders

% Clear checkjobs folder
system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,'/',p(idx).checkjobdir]);
 
%% Clear reference and weighting files

% Iteration number
if any(strcmp(avg_modes,p(idx).subtomo_mode))
    iter = p(idx).iteration;
elseif any(strcmp(ali_modes,p(idx).subtomo_mode))
    iter = p(idx).iteration+1;
end

% Filename suffix
switch p(idx).subtomo_mode        
    case {'ali_singleref','avg_singleref'}
        suffix = ['_',num2str(iter),'_*.em'];
    otherwise
        suffix = ['_',num2str(iter),'-*_*.em'];
end

% Parse fields
[n, v_fields] = parse_refname_volumes(p,idx,'cleanup');
for i = 1:numel(v_fields);
    system(['rm -f ',p(idx).rootdir,'/',n.(v_fields{i}),suffix]);
end

% Clean powerspectrum intermediates
if isfield(p(idx),'psfilename')
    if ~strcmp(p(idx).psfilename,'none')
        % Powerspec
        system(['rm -f ',p(idx).rootdir,'/',p(idx).psfilename,suffix]);
        % Bin wedge
        if ~any(strcmp(v_fields(1,:),'bin_wedge'))
            [ref_path,~,~] = fileparts(n.ref);
            n.bin_wedge = [ref_path,'/bin-wedge'];
            system(['rm -f ',p(idx).rootdir,'/',n.bin_wedge,suffix]);
        end
    end
end


%% Clear allmotl files
if any(strcmp(p(idx).subtomo_mode,ali_modes))
    
    % Clear motls folder
    [splitmotldir,~,~] = fileparts(p(idx).splitmotlname);
    system(['rsync -a --delete ',p(idx).rootdir,'/blank/ ',p(idx).rootdir,splitmotldir]);
    
    system(['rm -f ',p(idx).rootdir,'/',p(idx).allmotlname,'_',num2str(iter),'_*.em']);
end






