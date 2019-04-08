%% load_emfile

function load_emfile(p, o, idx, fields, mode)
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
% WW 11-2017

% Get node name
global nn

% Check check!!!
if nargin == 3
    mode = 'init';
elseif nargin ~= 4
    error(nn,'Achtung!!! load_emfile requires at least 3 inputs');
end

% Number of fields
n_fields = size(fields,2);

% Load files
for i = 1:n_fields
    
    % Check loading condition
    switch mode
        case 'init'
            load = true;        
        case 'refresh'            
            if strcmp(p(idx).(fields{i}),p(idx-1).(fields{i}))
                load = false;
            else
                load = true;
            end
    end
    % Load file
    if load
        try
            o.(fields{2,i}) = emread([p(idx).rootdir,'/',p(idx).(fields{1,i})]);
        catch
            error([nn,'Achtung!!! Error reading: ',p(idx).(fields{1,i})]);
        end
    end
end

end