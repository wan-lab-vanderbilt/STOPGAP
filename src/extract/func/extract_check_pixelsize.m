function o = extract_check_pixelsize(p,o,s,idx,tomo_idx)
%% extract_check_pixelsize
%
% WW 04-2021

%% Check pixelsize

% Check for pixelsize
if sg_check_param(p(idx),'pixelsize')
    disp([s.cn,'Getting input pixelsize from parameter file...']);       
    
    % Store pixelsize
    o.pixelsize = p(idx).pixelsize;
    
elseif sg_check_param(o,'wedgelist_name')
    disp([s.cn,'Getting input pixelsize from wedgelist...']);       
    
    % Find correct tomogram index
    wedge_idx = [o.wedgelist.tomo_num] == o.tomo_num(tomo_idx);
    
    % Store pixelsize
    pixelsizes = [o.wedgelist.pixelsize];
    o.pixelsize = pixelsizes(wedge_idx);
    
    
else
    disp([s.cn,'Getting input pixelsize from wedgelist...']);       
    
    % Read from header
    o.pixelsize = o.tomo_header.xlen/single(o.tomo_header.mx);
    
end
    
    
    




