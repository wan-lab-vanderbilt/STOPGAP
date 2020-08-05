function wait_for_them(compdir,compname,n_proc,wtime)
%% wait_for_them
% Wait for a number of parallel processes to finish. 
% 
% WW 01-2019

%% Wait for it....

% Check check
if nargin == 3
    wtime = 10;
elseif nargin ~= 4
    error('Achtung!!! Incorrect number of inputs!!!');
end

w = true;
while w
    pause(wtime);
    d = dir([compdir,'/',compname,'_*']);
    if numel(d) >= n_proc
        w = false;
    end
end

