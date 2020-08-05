function db_name = get_star_data_block(star_name)
%% get_star_data_block
% Read in a .star file and return the name of the first data block.
%
% WW 06-2019

%% Get data block name

% Open .star file
fid = fopen(star_name,'r');
star = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);

% Find target data block
data_idx = find(strncmp(star{1},'data_',5));

% Parse data block name
db_name = star{1}{data_idx(1)}(6:end);


