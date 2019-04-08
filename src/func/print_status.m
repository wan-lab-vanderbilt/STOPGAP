function n_back = print_status(string, n_back)
%% print_status
% A function for printing a status, overwriting a previous line.
%
% WW 11-2017

%% Print!!!

% Backspace string
back = repmat('\b',[1,n_back]);

% Print output
fprintf([back,string]);

% Return length of input string
n_back = numel(string);

