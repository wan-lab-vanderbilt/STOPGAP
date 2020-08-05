function p = sg_quaternion_multiply(varargin)
%% sg_quaternion_multiply
% A function to multiply an arbitrary number of quaternions. Each
% quaternion should be given as a quadruple in JPL quaternion format, i.e. 
% [x,y,z,w] or [x;y;z;w]. 
%
% NOTE: Keep in mind that quaternion multiplication is non-comunicative;
% rotations are performed right to left, i.e. last input to first input.
%
% WW 10-2017

%% Check check

% Number of quaternions
n_quat = nargin;
% Array for normalized quaternions
q = cell(n_quat,1);
% Check quaternion dimensions and normalize
for i = 1:n_quat
    if ~isvector(varargin{i}) || ~(numel(varargin{i}==4))
        error(['Achtung!!! Input ',num2str(i),' has incorrect dimensions!!!']);
    else
        q{i} = sg_quaternion_normalize(varargin{i});
    end
end

%% Perform quaternion multiplication

% Assign rightmost quaternion to final quaternion
p = varargin{end};

% Perform multiplications
idx = fliplr(1:(n_quat-1));
for i = idx
    
    % Temporary quaternion
    temp_p = zeros(size(p));
    
    % Multiplication
    temp_p(1) = (q{i}(1)*p(4)) + (q{i}(2)*p(3)) - (q{i}(3)*p(2)) + (q{i}(4)*p(1));
    temp_p(2) = (-q{i}(1)*p(3)) + (q{i}(2)*p(4)) + (q{i}(3)*p(1)) + (q{i}(4)*p(2));
    temp_p(3) = (q{i}(1)*p(2)) - (q{i}(2)*p(1)) + (q{i}(3)*p(4)) + (q{i}(4)*p(3));
    temp_p(4) = (-q{i}(1)*p(1)) - (q{i}(2)*p(2)) - (q{i}(3)*p(3)) + (q{i}(4)*p(4));
    
    % write out product
    p = temp_p;
end

% Normalize
p = sg_quaternion_normalize(p);

        