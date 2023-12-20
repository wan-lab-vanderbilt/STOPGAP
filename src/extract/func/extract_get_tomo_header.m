function o = extract_get_tomo_header(o,s,tomo_idx)
%% extract_get_tomo_header
% Read tomogram header
%
% WW 04-2021

%% Read header
disp([s.cn,'Reading header for tomogram: ',o.tomolist.tomo_name{tomo_idx}]);

o.tomo_header = sg_read_mrc_header(o.tomolist.tomo_name{tomo_idx});



