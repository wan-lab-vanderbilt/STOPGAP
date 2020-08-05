function rvec = will_quaternion_rotate(q,vec)
%% sg_quaternion_rotate
% A function to rotate a vector using quaternion conjucation, i.e. p'=qpq'.
% 
% Vector can be supplied as a quaternion or as a Cartesian vector. The
% result will be given in the same format.
%
% WW 10-2017

%% Check check!

% Check q
if ~isvector(q) || ~(numel(q)==4)
    error('Achtung!!! Rotation quaternion has incorrect dimensions!!!');
else
    if size(q,1) == 4
        q_type = 'long';
    else
        q_type = 'wide';
    end
end

% Check vec
if ~isvector(vec) || ~sum(numel(vec) == [3,4])
    error('Achtung!!! Vector has incorrect dimensions!!!');
else
    if size(vec,2) == 1
        vec_type = 'long';
        if numel(vec)==3
            p = cat(1,vec,0);
        end
    else
        vec_type = 'wide';        
        if numel(vec)==3
            p = cat(2,vec,0);
        end
    end
end

% Check length
if ~strcmp(q_type,vec_type)
    q = q';
end


%% Rotate!!!

% Magnitude of p (will_quaternion_multiply normalizes all quaternions)
mag_p = sqrt(sum(p.^2));

% Compute complex conjugate of q
conj_q = zeros(size(q));
conj_q(1:3) = -q(1:3);
conj_q(4) = q(4);

% Compute rotation
rvec = sg_quaternion_multiply(q,p,conj_q);
if numel(vec) == 3
    rvec = rvec(1:3);
end

% Unnormalize vector
rvec = rvec.*mag_p;



