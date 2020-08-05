function D = sg_pairwise_dist(X, Y)
% A function to determine the pairwise distance between two n-dimensional
% arrays. I found it after googling "matlab pairwise distance". It should
% be substantially faster than the matlab function pdist.
%
% A fix had to be implemented as the bsxfun changed in the matlab 8.x
% and produces rounding errors close to zero. This results in some numbers 
% becoming negative, making the distance array a complex array. This fix
% rounds all negative values to zero. 
%
% WW 02-2016


% Squares of the distances
sq_dist = (bsxfun(@plus,dot(X,X,1)',dot(Y,Y,1))-2*(X'*Y));

% Find negative values
neg = sq_dist < 0;
% Set negative values to zero
sq_dist(neg) = 0;

D = sq_dist.^0.5;