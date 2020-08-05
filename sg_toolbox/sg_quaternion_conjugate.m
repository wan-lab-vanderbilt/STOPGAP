function conj_q = sg_quaternion_conjugate(q)
%% sg_quaternion_conjugate
% Coomputes the conjugate of a quaternion.
%
% WW 11-2017


%% Compute conjugate of q
conj_q = zeros(size(q));
conj_q(1:3) = -q(1:3);
conj_q(4) = q(4);