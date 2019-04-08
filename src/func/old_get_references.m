function o = get_references(p,o,idx)
%% get_references
% A function to read in reference. Parameters are from the 'p' struct and
% input index (idx), and reference are read into the 'o' struct.
%
% WW 11-2017

%% Read references

switch p(idx).subtomo_mode

    case 'ali_singleref'
        % Read reference
        rname = [p(idx).alirefilename,'_',num2str(p(idx).iteration),'.em'];
        o.ref = read_em(p(idx).rootdir,rname);

        % Perform n-fold symmetrization of reference. If a volume VOL is assumed to have a n-fold symmtry axis along Z it can be rotationally symmetrized
        if p(idx).nfold > 1
            o.ref = tom_symref(o.ref,p(idx).nfold); 
        end
        o.n_ref = 1;

    case {'ali_multiclass', 'ali_multiref'}

        % Initialize reference array
        o.ref = zeros(o.boxsize,o.boxsize,o.boxsize,o.n_classes);

        % Read references
        for j = 1:o.n_classes
            % Read reference
            rname = [p(idx).alirefilename,'_',num2str(p(idx).iteration),'-',num2str(o.classes(j)),'.em'];
            o.ref(:,:,:,j) = read_em(p(idx).rootdir,rname); 

            % Perform n-fold symmetrization of reference. If a volume VOL is assumed to have a n-fold symmtry axis along Z it can be rotationally symmetrized
            if p(idx).nfold ~= 1
                o.ref(:,:,:,j) = tom_symref(o.ref(:,:,:,j),p(idx).nfold); 
            end

        end
        o.n_ref = o.n_classes;

end

end


