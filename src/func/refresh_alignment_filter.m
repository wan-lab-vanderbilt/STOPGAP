function o = refresh_alignment_filter(p, o, idx, mode)
%% refresh_alignment_filter
% A function to load an alignment filter into the 'o' array. If the mode is
% 'init', the loading will be forced. If not, the script will check on the
% parameters to determine if the filter should be reloaded. If there is no 
% alignment filter, the function will return.
%
% WW 02-2018


%% Initialize
% Get node name
global nn

% Check check!!!
if (nargin < 3) || (nargin > 4)
    error(nn,'Achtung!!! refresh_emfile requires at least 3 inputs');
end
if nargin == 3
    mode = 'init';
end

%% Check that field exists

% If field does not exist, clear filter and return
if ~isfield(p,'alignment_filtername')
    if isfield(o,'ali_filt')
        o = rmfield(o,'ali_filt');
    end
    return
elseif strcmp(p(idx).alignment_filtername,'none')    
    if isfield(o,'ali_filt')
        o = rmfield(o,'ali_filt');
    end
    return  
end

    
%% Refresh filter

    
% Check loading condition
switch mode
    case 'init'
        load = true;        
    case 'refresh'  
        if idx == 1
            load = true;
        elseif strcmp(p(idx).alignment_filtername,p(idx-1).alignment_filtername)
            if strcmp(p(idx).alignment_filtertype,'constant')
                load = false;
            else
                load = true;
            end
        else
            load = true;
        end
end

% Load file
if load
    
    switch p(idx).alignment_filtertype
        
        case 'constant'
            o.ali_filt = read_em(p(idx).rootdir,p(idx).alignment_filtername);
            
        case 'iterative'
            
            name = [p(idx).alignment_filtername,'_',num2str(p(idx).iteration),'.em'];
            o.ali_filt = read_em(p(idx).rootdir,name);
    end
end


end




