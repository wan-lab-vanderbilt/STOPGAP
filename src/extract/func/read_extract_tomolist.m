function tomolist = read_extract_tomolist(tomolist_name)
%% read_extract_tomolist
% Read a tomolist for subtomogram extraction.
%
% WW 04-2021

%% Read extraction tomolist


% Read file
fid = fopen(tomolist_name,'r');
temp_tomolist = textscan(fid,'%d %s');
fclose(fid);

% Initialize tomolist
tomolist = struct();

% Fill tomolist
tomolist.tomo_num = temp_tomolist{1};
tomolist.tomo_name = temp_tomolist{2};





