function o = extract_check_rescaling(p,o,s,idx)
%% extract_check_rescaling
% Check if output subtomograms will be rescaled.
%
% WW 04-2021

%% Check for rescaling

% Set rescalign
o.rescale = false;

% Check inputs
if sg_check_param(p(idx),'output_pixelsize')
    if p(idx).output_pixelsize ~= o.pixelsize
        o.rescale = true;
        o.output_pixelsize = p(idx).output_pixelsize;
    end
end

% Display some output
if o.rescale
    disp([s.cn,'Rescaling output subtomogram pixelsize to ',num2str(o.output_pixelsize),'A/pix...']);
else
    o.output_pixelsize = o.pixelsize;
    disp([s.cn,'Output subtomogram pixelsize is ',num2str(o.output_pixelsize),'...']);
end


