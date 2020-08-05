function sg_reflist_add_entry(reflist_name,ref_name,class,mask_name,symmetry)
%% sg_reflist_add_entry
% Add an entry to a STOPGAP reference list. If the reference list already
% exists, the list is appended.
%
% Inputs are:
% Name of reference list
% Reference root name
% Reference class (ignored for singleref)
% Name of real-space mask
% Symmetry of reference
%
% WW 06-2019

%% Generate list

% Initialize struct
r = struct('ref_name',ref_name,'class',class,'mask_name',mask_name,'symmetry',symmetry);
            
% Concatenate old list
if exist(reflist_name,'file')
    old_reflist = sg_reflist_read(reflist_name);
    r = cat(1,old_reflist,r);
end

% Write star file
sg_reflist_write(reflist_name,r);



