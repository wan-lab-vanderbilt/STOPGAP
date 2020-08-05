function v = initialize_eigenval_volumes(p,o,s,idx,v)
%%
% Read in eigenvolumes and compute Fourier transforms for eigenvalue
% calculation. 
%
% WW 06-2019

%% Initialize volumes
disp([s.nn,'Reading eigenvolumes...']);


% Read volumes and store FFTs
for i = 1:o.n_filt
    for j = 1:p(idx).n_eigs
        
        % Read volume
        name = [o.pcadir,'/',p(idx).eigenvol_name,'_',num2str(o.filtlist(i).filt_idx),'_',num2str(j),s.vol_ext];
        vol = read_vol(s,p(idx).rootdir,name);
        
        % Store FT
        field = ['ft_',num2str(i),'_',num2str(j)];
        v.(field) = fftn(vol);
        
    end
end



