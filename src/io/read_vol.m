function vol = read_vol(s,rootdir,filename)
%% read_vol
% Read volume; volume format is determined by the settings.
%
% WW 12-2018

%% Read vol

switch s.vol_ext
    
    case '.em'
        try
            vol = sg_emread([rootdir,'/',filename]);
        catch
            error([s.nn,'ACHTUNG!!! Error reading file ',filename,'!!!']);
        end                
    case {'.mrc','.rec','.st','ali'}
        try
            vol = sg_mrcread([rootdir,'/',filename]);
        catch
            error([s.nn,'ACHTUNG!!! Error reading file ',filename,'!!!']);
        end  
        
end

vol = single(vol);