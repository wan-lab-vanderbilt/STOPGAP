function write_vol(s,o,rootdir,filename,data)
%% write_vol
% Write a volume. Volume format is determined from the settings. For .mrc
% files, pixelsize is taken from the 'o' array.
%
% WW 12-2018

switch s.vol_ext
    
    case '.em'
        
        sg_emwrite([rootdir,'/',filename],data);
        
    case '.mrc'
        
        if sg_check_param(o,'pixelsize')
            sg_mrcwrite([rootdir,'/',filename],data,[],'pixelsize',o.pixelsize);
        else
            sg_mrcwrite([rootdir,'/',filename],data);
        end
        
end