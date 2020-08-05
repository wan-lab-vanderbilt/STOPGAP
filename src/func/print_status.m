function n_back = print_status(string, n_back)
%% print_status
% A function for printing a status, overwriting a previous line.
%
% WW 11-2017

%% Print!!!

% Backspace string
back = repmat('\b',[1,n_back]);

% Return length of input string
str_length = numel(string);

% Blank spacking to clear previous string
if n_back > str_length
    n_blank = n_back - str_length;
else
    n_blank = 0;
end
blank = char(zeros(1,n_blank));

% Print output
fprintf([back,string,blank]);

% Return n_back
n_back = numel([string,blank]);



