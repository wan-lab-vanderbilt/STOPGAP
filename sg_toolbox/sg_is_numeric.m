function status = sg_is_numeric(str)
%% sg_is_numeric
% Check if string has the elemenets of a number.
%
% WW 12-2018

%% Check check!

status = all(ismember(str,'0123456789+-.eDdD'));


