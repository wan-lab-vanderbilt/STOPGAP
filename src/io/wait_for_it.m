function wait_for_it(compdir,compname,wtime)
%% wait_for_it
% A function to wait for a subtomogram averaging step to finish. The
% process completion is communicated via a file with name 'compname' is
% written in the completion directory, 'compdir'. 'wtime' sets the time
% between checks in seconds. 
%
% WW 11-2017

%% Wait for it....

% Check check
if nargin == 2
    wtime = 10;
elseif nargin ~= 3
    error('Achtung!!! Incorrect number of inputs!!!');
end

w = true;
while w
    pause(wtime);
    if exist([compdir,'/',compname],'file')
        w = false;
    end
end