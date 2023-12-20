function [n_phi,n_psi,n_the] = sg_normalize_eulers(phi,psi,the)
%% sg_normlalize_eulers
% Normalize euler angles, with phi and psi between +/- 180 degrees and
% theta between 0 and 180 degrees. This is performed by going back and
% forth to rotation matrix format. 
%
% WW 08-2023

%% Normalize eulers

rmat = sg_euler2matrix(phi,psi,the);
[n_phi,n_psi,n_the] = sg_matrix2euler(rmat);


