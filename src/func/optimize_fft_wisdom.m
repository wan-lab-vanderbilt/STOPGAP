function optimize_fft_wisdom(boxsize,precision)
%% optimize_fft_wisdom
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
if numel(boxsize,1)
    boxsize = ones(1,3).*boxsize;
end
vol = rand(boxsize,precision);

% Clear previous wisdom
fftw(wis,[]);

% Plan new wisdom
fftw('planner','exhaustive');
fftn(vol);
fftn(vol);

% Store wisdom
fftinfo = fftw('swisdom');
fftw('swisdom',fftinfo);

