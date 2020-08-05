function sg_wedgelist_write(,wedgelistname,wedgelist)
%% write_wedgelist
% A function for writing a stopgap wedgelist. The function insures proper
% formatting of wedgelists.
%
% WW 06-2018

%% Check check!!!

% Get fields
fields = get_wedgelist_fields;

% Sort wedgelist fields
wedgelist = orderfields(wedgelist,fields(:,1));


%% Write output

stopgap_star_write(wedgelist,[rootdir,'/',wedgelistname],'stopgap_wedgelist',[],4,2);


