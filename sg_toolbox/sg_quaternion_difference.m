function r = sg_quaternion_difference(q1,q2, output)
%% sg_quaternion_difference
% A function to compute the difference, i.e. the intermediate rotation,
% between two quaterions. It does this by multiplying the first quaterion 
% by the conjugate of the second; for a rotation, q1 is the first rotation
% and q2 is conjugated. Output is either the intermediate quaternion 
% (output ='q'), in which case order matters, or the absolute angle 
% (output = 'angle') between the two.
%
% WW 11-2017

%% Check check

if numel(q1) ~= 4
    error('Achtung!!! q1 has an incorrect size!!!');
elseif numel(q2) ~= 4
    error('Achtung!!! q2 has an incorrect size!!!');
end
if nargin == 2
    output = 'angle';
elseif nargin ~=3
    error('Achtung!!! Incorrect number of inputs!!!');
end

%% Calculate difference

% Conjugate Q2
cq2 = sg_quaternion_conjugate(q2);

% Multiply quaternions
nq = sg_quaternion_multiply(q1,cq2);

% Check output
switch output
    case 'q'
        r = nq;
        
    case 'angle'
        [~,angle] = sg_quaternion2axisangle(nq);
        r = abs(angle);
end

