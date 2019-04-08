function o = get_references(p,o,idx)
%% get_references
% A function to read in reference. Parameters are from the 'p' struct and
% input index (idx), and reference are read into the 'o' struct.
%
% v1: WW 11-2017
% v2: WW 01-2018 Updated to store references in cell arrays. 
%
% WW 01-2018

%% Read references

% Initialize cell array
o.ref = cell(o.n_classes,1);

% Check reference name
if isfield(p,'refilename')
    ref_name = p(idx).refilename;
else
    ref_name = p(idx).ali_refilename;
end

% Load and symmetrize references
switch p(idx).subtomo_mode

    case 'ali_singleref'
        % Read reference
        rname = [ref_name,'_',num2str(p(idx).iteration),'.em'];
        ref = read_em(p(idx).rootdir,rname);

        % Perform n-fold symmetrization of reference. If a volume VOL is assumed to have a n-fold symmtry axis along Z it can be rotationally symmetrized
        if p(idx).nfold > 1
            ref = tom_symref(ref,p(idx).nfold); 
        end
        
        % Store reference
        o.ref{1} = ref;
        o.n_ref = 1;

    case {'ali_multiclass', 'ali_multiref'}

        % Read references
        for j = 1:o.n_classes
            % Read reference
            rname = [ref_name,'_',num2str(p(idx).iteration),'-',num2str(o.classes(j)),'.em'];
            ref = read_em(p(idx).rootdir,rname); 

            % Perform n-fold symmetrization of reference. If a volume VOL is assumed to have a n-fold symmtry axis along Z it can be rotationally symmetrized
            if p(idx).nfold ~= 1
                ref = tom_symref(ref,p(idx).nfold); 
            end
            
            % Store reference
            o.ref{j} = ref;

        end
        o.n_ref = o.n_classes;

end




