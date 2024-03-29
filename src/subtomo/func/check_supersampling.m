function o = check_supersampling(p,o,s,idx)
%% check_supersampling
% Check for supersampling during average.
% 
% WW 11-2018

%% Check check!!!

% Check for param existence
if sg_check_param(p(idx),'avg_ss')
    disp([s.cn,'Performing averaging with super-sampling!!!']);
    o.avg_ss = p(idx).avg_ss;
else
    o.avg_ss = 1;
end

% Round supersampling factors to ensure even integer boxsize
ss_boxsize = round_to_even(o.boxsize.*o.avg_ss);
o.avg_ss = ss_boxsize(1)./o.boxsize(1);

% Write supersampled sizes
o.ss_boxsize = o.boxsize*o.avg_ss;
o.ss_cen = floor(o.ss_boxsize/2)+1;
o.ss_pixelsize = o.pixelsize/o.avg_ss;
o.ss_unbinned_pixelsize = o.unbinned_pixelsize/o.avg_ss;



