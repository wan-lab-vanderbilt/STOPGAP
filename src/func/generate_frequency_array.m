function f = generate_frequency_array(p,o,f,idx,mode)
%% generate_frequency_array
% A function to generate a frequency array. This will be used for further
% calculations such as CTF filters.
%
% WW 01-2018

%% Generate frequency array

% Euclidean pixel distances
[x,y,z] = ndgrid(-floor(o.boxsize/2):-floor(o.boxsize/2)+o.boxsize-1,...
                 -floor(o.boxsize/2):-floor(o.boxsize/2)+o.boxsize-1,...
                 -floor(o.boxsize/2):-floor(o.boxsize/2)+o.boxsize-1);

% Projected reciprocal distance array
rx = x./(o.boxsize*p(idx).pixelsize);
ry = y./(o.boxsize*p(idx).pixelsize);
rz = z./(o.boxsize*p(idx).pixelsize);
freq_array = sqrt((rx.^2)+(ry.^2)+(rz.^2));

% Store frequencies
if strcmp(mode,'align')
    f.freq_array = ifftshift(freq_array);
elseif strcmp(mode,'aver')
    f.freq_array = freq_array;
end





