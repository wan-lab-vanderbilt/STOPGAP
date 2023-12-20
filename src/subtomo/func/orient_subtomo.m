function oriented_subtomo = orient_subtomo(p,o,s,idx,f,subtomo_num,x,y,z,phi,psi,the,lpf)
%% orient_subtomo
% Rotate and shift subtomogram into the determined alignment postion for
% parallel averaging.
%
% WW 09-2023

%% Orient subtomogram

% Read subtomogram
subtomo_name = [o.subtomodir,'/',p(idx).subtomo_name,'_',s.subtomo_num(subtomo_num),s.vol_ext];
try
    subtomo = read_vol(s,o.rootdir,subtomo_name);
catch
    error([s.cn,'ACHTUNG!!! Error reading file ',subtomo_name,'!!!']);
end


% Rescale for supersampling averaging
subtomo = sg_fourier_rescale_volume(subtomo,o.avg_ss);

% Prepare filter
filt = ifftshift(f.pfilt.*lpf);

% Transform subtomo
ft_subtomo = fftn(subtomo);

% Filter subtomo
filt_subtomo = real(ifftn(ft_subtomo.*filt));

% Normalize subtomo
filt_subtomo = (filt_subtomo - mean(filt_subtomo(:)))./std(filt_subtomo(:));


% Rotate subtomogram
% subtomo = sg_rotate_vol(sg_shift_vol(norm_subtomo,[-x,-y,-z]),[-psi,-phi,-the],[],'cubic');
oriented_subtomo = sg_rotate_vol(sg_shift_vol(filt_subtomo,[-x,-y,-z]),[-psi,-phi,-the],[],'linear');

% Renormalize
oriented_subtomo = (oriented_subtomo - mean(oriented_subtomo(:)))./std(oriented_subtomo(:));   



