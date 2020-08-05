function [pairs,idx] = sg_pca_determine_unique_pairs(n)
%% sg_pca_determine_unique_pairs
% Calculate all unique pairs for a given number of items. For large arrays,
% this is much faster than trying to do the same operation with nchoosek.
%
% WW 04-2019

%% Calculate pairs

% Take lower half of identity matrix
mat = tril(true(n,n),-1);

% Find indices of matrix positions
idx = find(mat);

% Convert indices to subscripts
[x,y] = ind2sub([n,n],idx);

% Concatenate pairs
pairs = cat(2,x,y);

