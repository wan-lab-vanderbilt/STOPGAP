function data_8bit = sg_rescale_to_16bit(data)
%% sg_rescale_to_8bit
% Take input data array and rescale values between the min and max of 16bit 
% integers. Intermediate values are rounded to the nearest integer.
%
% WW 11-2018


%% Rescale!

% Set min to zero
min_val = min(data(:));
data = data - min_val;

% Scale max to 65536
max_val = max(data(:));
data = data.*(65536/max_val);

% Float range to -32768 to 32767
data = round(data)-32768;

% Convert
data_8bit = int16(data);



