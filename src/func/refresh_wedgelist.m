function o = refresh_wedgelist(p, o, idx, mode)

%% refresh_wedgelist
% A function to load a wedgelist into the 'o' struct array. Parameters are
% taken from the 'p' struct array, using the input index (idx) and fields
% (fields). The fields array is a 2xN array, where the top row are the
% p.field and the bottom row are the o.fields. 
%
% Mode can be 'init' for initializing or 'refresh' to referesh.
% Initializing simply reads in the file. Refresh checks if there is a name
% change between idx and idx-1; files are reloaded only in the case of a
% name change.  
%
% WW 01-2018

%% Initialize
% Get node name
global nn

% Check check!!!
if (nargin < 3) || (nargin > 4)
    error(nn,'Achtung!!! refresh_wedgelist requires at least 3 inputs');
end
if nargin < 4
    mode = 'init';
end


%% Refresh EM file

% Check loading condition
switch mode
    case 'init'
        load_file = true;        
    case 'refresh'            
        if idx == 1
            load_file = true;
        elseif strcmp(p(idx).wedgelistname,p(idx-1).wedgelistname)
            load_file = false;
        else
            load_file = true;
        end
end
% Load file
if load_file
    switch p(idx).wedgelist_type
        case 'wedge'
            o.wedgelist = read_em(p(idx).rootdir,p(idx).wedgelistname);
        case 'slice'
            load([p(idx).rootdir,'/',p(idx).wedgelistname]);
            o.wedgelist = wedgelist;
    end    
end

