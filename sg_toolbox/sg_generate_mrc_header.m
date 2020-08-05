function header = sg_generate_mrc_header(header_fields)
%% 
% Generate a default .mrc header. If header_fields are not given, the
% fields are intialized using default values. 
%
% WW 06-2018

%% Check check

if nargin == 0
    header_fields = sg_default_mrc_header_fields;
end

%% Generate header

header = struct();

for i = 1:size(header_fields,1)
    header.(header_fields{i,1}) = header_fields{i,2};
end


