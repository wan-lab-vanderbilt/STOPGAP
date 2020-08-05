function declare_empty_class(p,o,s,v,idx,class)
%% declare_empty_class
% Write output files to show that  class has emptied during averaging.
%
% WW 08-2019

%% Declare empty class
warning([s.nn,'ACHTUNG!!! Class',num2str(class),' has emptied during averaging!!!']);

% Open file
warn_name = [o.refdir,'/warning_',v.out_ref_names{3},'.txt'];
fid = fopen([p(idx).rootdir,'/',warn_name],'w');

% Issue warning
fprintf(fid,'%s',['ACHTUNG!!! Class ',num2str(class),' has emptied during averaging!!!']);
fclose(fid);

% Write completion flag
system(['touch ',p(idx).rootdir,'/',o.tempdir,'/emptyclass_',num2str(p(idx).iteration),'_',num2str(class)]);





