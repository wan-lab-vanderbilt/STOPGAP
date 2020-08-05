function num = round_to_even(num)
%% round_to_even
% Round an number to the nearest even integer.
%
% WW 06-2018

%% Round

% Round down
num = floor(num);

% Calculate modulo
rem = mod(num,2);

% Round up odd numbers
num = num + rem;


