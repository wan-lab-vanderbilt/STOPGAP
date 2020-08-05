function reflist = sg_reflist_read(reflist_name)
%% sg_reflist_read
% Read a STOPGAP reference list.
%
% WW 06-2019

%% Read list

reflist = stopgap_star_read(reflist_name,false,{'str','num','str','str'},'stopgap_reference_list');

end