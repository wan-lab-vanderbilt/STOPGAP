function [o,v,ali] = pearson_scoring_function(o,v,mode,f,ali)
%% pearson_scoring_function
% A function for intializing, preparing, and refining subtomogram alignment
% using a real-space Pearson correlation function. In this function, the
% shifts are directly refined using a maximization algorithm. 
%
% WW 04-2018

%% Calculate function

switch mode
    
    case 'init'        
        
        % Non-zero Fourier indices
        v.f_idx = (o.bandpass.*f.bin_wedge)>0;
        
        % Calculate grid
        v.grid = calculate_grid(o.boxsize,'align');

        
        
    case 'prep'
        
        % Filter subtomo
        ft_subtomo = fftn(v.subtomo);
        v.filt_subtomo =real(ifftn(ft_subtomo.*f.pfilt.*o.bandpass)); 
        
        % Non-zero Fourier indices
        v.f_idx = (o.bandpass.*f.bin_wedge)>0;

        % Store gridpoints
        v.x = v.grid.x(v.f_idx);
        v.y = v.grid.y(v.f_idx);
        v.z = v.grid.z(v.f_idx);        
        
        
    case 'score'
        
        % Rotate mask and reference
        v.rot_mask = tom_rotate(o.mask,[ali.phi,ali.psi,ali.the]);
        v.rot_ref = tom_rotate(o.ref{v.ref_num},[ali.phi,ali.psi,ali.the]);
        
        % Get mask info
        v.m_idx = v.rot_mask > 0;
        v.n_pix = sum(v.rot_mask(v.m_idx));
        
        % Apply mask and prepare for pearson correlation        
        m_subtomo = v.filt_subtomo(v.m_idx).*v.rot_mask(v.m_idx);
        v.m_subtomo = m_subtomo - (sum(m_subtomo)./v.n_pix);
        v.m_subtomo_ss = sum(v.m_subtomo.^2);
        
        
        
        % Minimze phase residual
        pearson_fun = @(shift) calculate_pearson(o,v,f,shift);                  
        [shift,dcc] = fminsearch(pearson_fun,ali.old_shift);
        
        % For optimal score, update parameters
        score = 1-dcc;
        if score > ali.score
            ali.score = score;
            ali.phi_opt = ali.phi;
            ali.psi_opt = ali.psi;
            ali.the_opt = ali.the;
            ali.shift = shift;
        end
        
    otherwise
        error([nn,'ACHTUNG!!! Invalid mode!!!']);

        
end

end



function dcc = calculate_pearson(o,v,f,shift)   

%% calculate_pearson
% A function to perform a shift and calculate a Pearson correlation

% Calcualte shift vectors
shift = shift./o.boxsize;

% Signal delay for shift
tau = (shift(1)*v.x) + (shift(2)*v.y) + (shift(3)*v.z);

% Calculate phase shift
phase_shift = exp(-2*pi*1i*tau);

% Transform reference and split amplitudes and phases
ft_ref = fftn(v.rot_ref);
ft_ref = ft_ref.*f.rfilt.*o.bandpass;

% Shift template
ft_ref(v.f_idx) = ft_ref(v.f_idx).*phase_shift;
shift_ref = ifftn(ft_ref);

% Apply mask and prepare for pearson correlation        
m_ref = shift_ref(v.m_idx).*v.rot_mask(v.m_idx);
m_ref = m_ref - (sum(m_ref)./v.n_pix);
m_ref_ss = sum(m_ref.^2);

% Calcuate CC
cc = sum(m_ref.*v.m_subtomo)/sqrt(m_ref_ss*v.m_subtomo_ss);

% Return difference for minimizer function
dcc = 1-cc;

end






