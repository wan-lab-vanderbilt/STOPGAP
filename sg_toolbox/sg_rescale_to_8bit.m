function data_8bit = sg_rescale_to_8bit(data)
%% sg_rescale_to_8bit
% Take input data array and rescale values between -128 and 127. 
% Intermediate values are rounded to the nearest integer.
%
% WW 11-2018


%% Rescale!

% Set min to zero
min_val = min(data(:));
data = data - min_val;

% Scale max to 255
max_val = max(data(:));
data = data.*(255/max_val);

% Float range to -128 to 127
data = round(data)-128;

% Convert
data_8bit = int8(data);



