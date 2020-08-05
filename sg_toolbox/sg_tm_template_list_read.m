function tlist = sg_tm_template_list_read(tlist_name)
%% sg_tm_template_list_read
% Read a template list for STOPGAP Template Matching. 
%
% WW 03-2018

%% Read list

% Read input
tlist = stopgap_star_read(tlist_name,false,[],'sg_tm_template_list');

