function sg_tm_make_tomolist(tm_tomolist_name,sg_tomolist_name,tomo_dir,tomo_ext,mask_dir,mask_suffix,mask_ext)
%% sg_tm_make_tomolist
% A function to read a TOMOMAN tomolist and generate a new tomolist for
% STOPGAP template matching.
%
% tm_tomolist_name = name of input TOMOMAN tomolist
% sg_tomolist_name = name of output STOPGAP TM tomolist
% tomo_dir = full path to directory of tomograms to be matched
% tomo_ext = extension of tomograms; for TOMOMAN this is generally .rec
% mask_dir = optionally path to boundary masks. Leave empty to skip
% mask_suffix = suffix for mask (typically something like 'boundary')
% mask_ext = extension of mask, e.g. '.mrc'
%
% WW 01-2026

% tm_tomolist_name = 'tomolist.mat';
% sg_tomolist_name = 'sg_tm_tomolist.txt';
% tomo_dir = [pwd,'/tomo/']
% tomo_ext = '.rec';
% mask_dir = [pwd,'/mask/'];
% mask_suffix = 'boundary';
% mask_ext = '.mrc';

%% Check check

% Check dir slashes
tomo_dir = sg_check_dir_slash(tomo_dir);
mask_dir = sg_check_dir_slash(mask_dir);

% Check mask_suffix
if ~isempty(mask_suffix)
    mask_suffix = ['_',mask_suffix];
end

    

%% Initialize

% Read tomolist
tomolist = tm_read_tomolist([],tm_tomolist_name);
n_tomos = numel(tomolist);

% Open output file
fid = fopen(sg_tomolist_name,'w');

%% Write tomolist

for i = 1:n_tomos
    
    % Check for skip
    if tomolist(i).skip
        continue
    end
    
    % Check if aligned
    if ~tm_check_if_aligned(tomolist(i))
        continue
    end
    
    % Parse name of stack used for alignment
    switch tomolist(i).alignment_stack
        case 'unfiltered'
            process_stack = tomolist(i).stack_name;
        case 'dose-filtered'
            process_stack = tomolist(i).dose_filtered_stack_name;
        otherwise
            error([p.name,'ACTHUNG!!! Unsuppored stack!!! Only "unfiltered" and "dose-filtered" supported!!!']);
    end        
    [~,tomo_name,~] = fileparts(process_stack);
    
    % Check for tomo
    if ~exist([tomo_dir,tomo_name,tomo_ext],'file')
        warning(['ACHTUNG!!! Tomogram ',tomo_name,' not found!!! Moving to next tomogram...']);
        continue
    end   
    
    % Check for mask
    if ~isempty(mask_dir)
        mask_name = [mask_dir,tomo_name,mask_suffix,mask_ext];
        if ~exist(mask_name,'file')
            error(['ACHTUNG!!! Missing mask: ',mask_name]);
        end
    else
        mask_name = [];
    end
    
    % Write output
    fprintf(fid,'%s\n',[num2str(tomolist(i).tomo_num),' ',tomo_dir,tomo_name,tomo_ext,' ',mask_name]);    
    
end


% Close file
fclose(fid);


