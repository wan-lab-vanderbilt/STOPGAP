function norm_q = sg_quaternion_normalize(q)
%% sg_quaternion_normalize
% A function to normalize quaternions, based on the principle that for a
% unit quaternion, ||q|| = 1.
%
% WW 10-2017

%% Normalize

magnitude = sqrt(sum(q.^2));
norm_q = q./magnitude;