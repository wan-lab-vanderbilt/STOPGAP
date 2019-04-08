function o = refresh_emfile(p, o, idx, fields, mode, skipcase)

%% refresh_emfile
% A function to load an .em file into the 'o' struct array. Parameters are
% taken from the 'p' struct array, using the input index (idx) and fields
% (fields). The fields array is a 2xN array, where the top row are the
% p.field and the bottom row are the o.fields. 
%
% Mode can be 'init' for initializing or 'refresh' to referesh.
% Initializing simply reads in the file. Refresh checks if there is a name
% change between idx and idx-1; files are reloaded only in the case of a
% name change. 
%
% Sometimes rather than loading a volume, a string should be stored
% instead; i.e. setting a variable to 'none', or not loading a ccmask
% during 'noshift'. In these cases, the strings that should be passed can
% be supplied in the skipcase array. The skipcase array is a dictionary
% used to check the filenames; for matches the string is passed to the o
% struct. 
%
% v1: WW 11-2017
% v2: WW 01-2018 Small bug fixes.
%
% WW 01-2018

%% Initialize
% Get node name
global nn

% Check check!!!
if (nargin < 3) || (nargin > 6)
    error(nn,'Achtung!!! refresh_emfile requires at least 3 inputs');
end
if nargin < 5
    mode = 'init';
end
if nargin < 6
    skipcase = {''};
end

%% Refresh EM file

% Number of fields
n_fields = size(fields,2);

% Load files
for i = 1:n_fields
    
    % Check loading condition
    switch mode
        case 'init'
            load = true;        
        case 'refresh'  
            if idx == 1
                load = true;
            elseif strcmp(p(idx).(fields{1,i}),p(idx-1).(fields{1,i}))
                load = false;
            else
                load = true;
            end
    end
    % Load file
    if load
        skiptest = strcmp(p(idx).(fields{1,i}),skipcase);
        if any(skiptest)
            o.(fields{2,i}) = p(idx).(fields{1,i});
        else
            o.(fields{2,i}) = read_em(p(idx).rootdir,p(idx).(fields{1,i}));
        end
    end
end

end
