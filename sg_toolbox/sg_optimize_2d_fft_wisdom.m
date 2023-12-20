function sg_optimize_2d_fft_wisdom(img_size,precision)
%% sg_optimize_2d_fft_wisdom
% Optimize the wisdom of the fftw algorithm to current boxsize.
%
% WW 12-2018


%% Check check

% Default precision
if (nargin == 1) || isempty(precision)
    precision = 'single';
end

% Check precision input
switch precision
    case 'single'
        wis = 'swisdom';
    case 'double'
        wis = 'dwisdom';
    otherwise
        error('ACHTUNG!!! Only "single" and "double" precision supported!!!');
end
    
    

%% Optimize fft wisdom for boxsize

% Initialize volume
if numel(img_size,1)
    img_size = ones(1,2).*img_size;
end
img = rand(img_size,precision);

% Clear previous wisdom
fftw(wis,[]);

% Plan new wisdom
fftw('planner','exhaustive');
fft2(img);
fft2(img);

% Store wisdom
fftinfo = fftw('swisdom');
fftw('swisdom',fftinfo);

