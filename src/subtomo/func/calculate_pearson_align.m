function dcc = calculate_pearson_align(o,v,ref,mask,shift)   
%% calculate_pearson_align
% A function to perform a shift and calculate a Pearson correlation
%
% WW 07-2021

%% Shift subtomogram

% Calcualte shift vectors
shift_vec = shift(:)./o.boxsize(:);

% Signal delay for shift
tau = (shift_vec(1)*v.grid.x) + (shift_vec(2)*v.grid.y) + (shift_vec(3)*v.grid.z);

% Calculate phase shift
phase_shift = exp(-2*pi*1i*tau);

% Apply phase shift
subtomo = v.subtomo.*phase_shift;


%% Calculate correlation

% Calculate shifted subtomo
subtomo = real(ifftn(subtomo));

% Mask and normalize
subtomo = normalize_under_mask(subtomo,mask);

% Calculate correlation
cc = sg_pearson_correlation(ref,subtomo);

dcc = 1-cc;



% %% Shift subtomogram
% 
% % Calcualte shift vectors
% % shift = shift./o.boxsize;
% if o.fcrop
%     shift = shift./o.full_boxsize;
% else
%     shift = shift./o.boxsize;
% end
% 
% 
% % Signal delay for shift
% tau = (shift(1)*v.x) + (shift(2)*v.y) + (shift(3)*v.z);
% 
% % Calculate phase shift
% phase_shift = exp(-2*pi*1i*tau);
% 
% % Apply phase-shift to Fourier space subtomogram 
% sh_subtomo = zeros(o.boxsize,'single');
% sh_subtomo(v.f_idx) = v.subtomo(v.f_idx).*phase_shift;
% 
% if o.fcrop
%     sh_subtomo = uncrop_fftshifted_vol(sh_subtomo, o.f_idx);
% end
% 
% 
% %% Calculate correlation
% 
% % Inverse transform subtomogram
% sh_subtomo = real(ifftn(sh_subtomo));
% 
% % Apply mask and normalize
% sh_subtomo = sh_subtomo(m_idx).*m_val;
% sh_subtomo = (sh_subtomo - mean(sh_subtomo))./std(sh_subtomo);  % Normalize
% 
% % Sum of squares
% s_ss = sum(sh_subtomo.^2);
% r_ss = sum(ref.^2);
% 
% % Calculate CC
% cc = sum(sh_subtomo.*ref)/sqrt(s_ss*r_ss); % Pre-normalized Pearson CC
% 
% 
% % Return difference for minimizer function
% dcc = 1-cc;

end