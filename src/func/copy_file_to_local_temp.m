function time = copy_file_to_local_temp(copy_core,remote_dir,local_dir,comm_dir,comm_name,wait_time,file_name,list,copy_function)
%% copy_file_to_local_temp
% Copy a file from remote storage to a local temporary folder. The copy
% core copies the files and writes a completion file to the local comm_dir.
% Other cores wait for completion.
%
% Files to be copied can be given as input files or a text list of files.
%
% WW 03-2021


%% Check check

% Check copy function
if (nargin < 9) || isempty(copy_function)
    % Set default function to tar
    copy_function = 'tar';
else
    if ~strcmp(copy_function,{'tar','rsync'})
        error(['ACHTUNG!!! ',copy_function,' is not a supported copying method.']);
    end
end
    

% If list is not given, assume single file
if (nargin == 7) || isempty(list)
    list = false;
end

% Blank time
time = [];

%% Copy files

% Check for copy core
if copy_core
    
    switch copy_function
        
        
        case 'rsync'
            disp('Copying files using rsync...');
            tic;
            if list
                system(['rsync -a --files-from=',file_name,' ',remote_dir,' ',local_dir]);
            else
                system(['rsync -a ',remote_dir,file_name,' ',local_dir,file_name]);
            end
            time = toc;
            
            
        % Copy using tar
        case 'tar'
            disp('Copying files using tar...');
            tic;
            if list
                system(['(cd ',remote_dir,'; tar -cf - -T ',file_name,') | tar -C ',local_dir,' -xf -']);
            else
                system(['(cd ',remote_dir,'; tar -cf - ',file_name,') | tar -C ',local_dir,' -xf -']);
            end
            time = toc;
            
    end
    
    
    % Write completion file
    system(['touch ',local_dir,'/',comm_dir,'/',comm_name]);

else
    
    % Wait for wedgelist to be copied
    wait_for_it([local_dir,'/',comm_dir,'/'],comm_name,wait_time);
    
end
    