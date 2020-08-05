%% sg_calcualte_fsc
% A function for calculating the FSC of two halfmaps using a
% 'mask-corrected' phase-randomization approach (see: 
% doi:10.1016/j.ultramic.2013.06.004). Phase-randomization can produce
% random artifacts in the FSC plot; averaging repeated randomizations can
% produce a better estimate of the true mask-corrected FSC. 
%
% The two halfmaps can then be averaged using figure-of-merit weighting and
% b-factor sharpening (see: 10.1016/j.jmb.2003.07.013).
%
% WW 07-2018


%% Inputs


% References
refA_name = 'ref_sg_sp_pc21604_i100_A_1.em';
refB_name = 'ref_sg_sp_pc21604_i100_B_1.em';

% FSC mask
mask_name = 'bin1_mask192_cr_g3.em';

% Volume parameters
symmetry = 'C1';      % Symmetry operator. 'C1' for no symmetry.
pixelsize = 2.7;     % In Angstroms

% Output name
ref_avg_name = 'ref_sg_sp_pc21604_i100_b600.mrc';  % Name of output filtered reference. Set to 'none' for no averaging.
flip_density = 1;

% Figure-of-merit weighitng
apply_fom = 1;     % (1 = on, 0 = off) Only disable if already applied.

% B-factor sharpening
bfactor = -600;     % Set to 0 for no sharpening.
fsc_thresh = 0.143; % FSC-value for lowpass filter threshold  
edge_smooth = 3; % Smooth box edge. 0 = off, otherwise odd number must be given.
plot_filt = 0;  % Plot sharpening filter

% Plotting parameters
plot_diagnostic = 1;        % Plot diagnostic plots the uncorrected, corrected, and mask FSC curves. Disabling plots cumulative corrected curves, allowing for direct comparison of runs.
resolution_label = 0;       % (1 = on, 0 = off)
res_label = [32,16,8,4,2];    % X-axis label resolutions (in Angstroms). Labels beyond Nyquist are ignored.



% FSC calculation options
fourier_cutoff = 5; % Phase randomization cutoff resolution (in pixels). Pretty much a fudge factor. 5-15 seems reasonable... -WW
n_repeats = 10;      % More repeats produces better estimate, but longer calculation time.


%% Initialize 
% Read references
refA = sg_volume_read(refA_name);
refB = sg_volume_read(refB_name);

% Size of edge of box
boxsize = size(refA,1);

% Read mask
if ~strcmp(mask_name ,'none')
    mask = sg_volume_read(mask_name);
else
    mask = ones(size(refA));
end

% Apply symmetry
if ~strcmp(symmetry,'C1')
%     mask = sg_symmetrize_volume(mask,symmetry);
    refA = sg_symmetrize_volume(refA,symmetry);
    refB = sg_symmetrize_volume(refB,symmetry);
end

% Apply masks
mrefA = refA.*mask;
mrefB = refB.*mask;


% Fourier transforms of masked structures
mftA = fftshift(fftn(mrefA));
mftB = fftshift(fftn(mrefB));


%% Initial calculations for phase-randomized density maps

% Calculate pixel distance array
R = sg_distancearray(refA,1);

% Determine for phase randomization
pr_sub = (R > fourier_cutoff);
pr_idx = find(pr_sub);
n_pr = size(pr_idx,1);

% Calculate Fourier transforms
ftA = fftshift(fftn(refA));
ftB = fftshift(fftn(refB));

% Split phases and amplitudes of high resolution data
phase_A = angle(ftA);
phase_B = angle(ftB);
amp_A = abs(ftA);
amp_B = abs(ftB);


%% Calculate initial steps of FSC calculation

% Initial calculations for FSC
AB_cc = mftA.*conj(mftB);     % Complex conjugate of A and B
intA =  mftA.*conj(mftA);     % Intensity of A
intB =  mftB.*conj(mftB);     % Intensity of B


%% Cacluate shell masks

% Number of Fourier Shells
n_shells = boxsize/2;  % Hardcoded to half the box-size

% Precalculate shell masks
shell_mask = cell(n_shells,1);
for i = 1:n_shells
    % Shells are set to one pixel size
    shell_start = (i-1);
    shell_end = i;
    
    % Generate shell mask
    temp_mask = (R >= shell_start) & (R < shell_end);
    
    % Write out linearized shell mask
    shell_mask{i} = temp_mask(:);
end


%% Calculate normal FSC

% Normal shell arrays
AB_cc_array = zeros(1,n_shells); % Complex conjugate of A and B
intA_array = zeros(1,n_shells); % Intenisty of A
intB_array = zeros(1,n_shells); % Intenisty of B

for i = 1:n_shells
    % Write normal outputs
    AB_cc_array(i) = sum(AB_cc(shell_mask{i}));
    intA_array(i) = sum(intA(shell_mask{i}));
    intB_array(i) = sum(intB(shell_mask{i}));
end

% Normal FSC
fsc = real(AB_cc_array./sqrt(intA_array.*intB_array));



%% Repeat phase-randomized FSC calculations

% Intialize randomized FSC array
rfsc = zeros(n_repeats,n_shells);

% Random shell arrays
rAB_cc_array = zeros(1,n_shells); % Complex conjugate of A and B
rintA_array = zeros(1,n_shells); % Intenisty of A
rintB_array = zeros(1,n_shells); % Intenisty of B

% Repeate randomization calculation
for r = 1:n_repeats
    
    % Randomize phases
    rphase_A = phase_A;
    rphase_B = phase_B;
    rphase_A(pr_idx) = phase_A(pr_idx(randperm(n_pr)));
    rphase_B(pr_idx) = phase_B(pr_idx(randperm(n_pr)));

    % Apply randomized phases to reference FTs
    rftA = amp_A.*exp(rphase_A*sqrt(-1));
    rftB = amp_B.*exp(rphase_B*sqrt(-1));

    % Generate phase-randomized real-space maps
    rrefA = ifftn(ifftshift(rftA));
    rrefB = ifftn(ifftshift(rftB));

    % Apply masks
    mrrefA = rrefA.*mask;
    mrrefB = rrefB.*mask;

    % Fourier transforms of masked structures
    mrftA = fftshift(fftn(mrrefA));
    mrftB = fftshift(fftn(mrrefB));
    
    % Initial calculations for phase-randomized FSC
    rAB_cc = mrftA.*conj(mrftB);     % Complex conjugate of A and B
    rintA =  mrftA.*conj(mrftA);     % Intensity of A
    rintB =  mrftB.*conj(mrftB);     % Intensity of B
    
    % Sum numbers for each shell
    for i = 1:n_shells
        % Write phase randomized outputs
        rAB_cc_array(i) = sum(rAB_cc(shell_mask{i}));
        rintA_array(i) = sum(rintA(shell_mask{i}));
        rintB_array(i) = sum(rintB(shell_mask{i}));
    end
    
    % Phase-randomized FSC
    rfsc(r,:) = real(rAB_cc_array./sqrt(rintA_array.*rintB_array));

    
end

corr_fsc = mean((repmat(fsc,[n_repeats,1])-rfsc)./(1-rfsc),1);
corr_fsc(1:fourier_cutoff-1) = fsc(1:fourier_cutoff-1);

%% Plot

% Calculate mean rfsc
m_rfsc = mean(rfsc,1);

% Plot corrected FSC
if plot_diagnostic == 1
    figure
    hold on
    plot(1:n_shells,corr_fsc,'LineWidth',2,'Color','k')
    plot(1:n_shells,fsc,'LineWidth',1,'Color','b');
    plot(1:n_shells,m_rfsc,'LineWidth',1,'Color','r');
    % Add legend
    legend('Corrected FSC','Uncorrected FSC','Phase-randomized FSC')
else
    plot(1:n_shells,corr_fsc,'LineWidth',1);
    hold on
end


% Apply Y-axis settings
grid on
axis ([0 n_shells -0.1 1.05]);
set(gca, 'yTick', [0 0.143 0.5 1.0]);
ylabel('Fourier Shell Correlation','FontSize',14);


% Label X-axis with resolution labels
if resolution_label == 1
    
    % Remove labels beyond nyquist
    res_keep = res_label >= (pixelsize*2);
    res_label = res_label(res_keep);
    
    % Number of labels
    n_res = numel(res_label);

    % X-value for each label
    x_res = zeros(n_res,1);
    for i = 1:n_res
        x_res(i) = (boxsize*pixelsize)/res_label(i);
    end

    set (gca, 'XTickLabel', res_label)
    set (gca, 'XTick', x_res)
    xlabel('Resolution (Angstroms)','FontSize',14);
    
else
    xlabel('Resolution (1/Angstrom)','FontSize',14);
end

% Set position
set(gca,'units','normalized','position',[0.15,0.15,0.75,0.75])



%% Calculate FSCs at points of interest
% Points of interest
fsc_points = [0.5, 0.143];
n_points = size(fsc_points,2);
% Array to hold FSC values
fsc_values = zeros(1,n_points);

for i = 1:n_points

    % Find point after value
    x2=find(corr_fsc(3:end)<=fsc_points(i),1)+2;
    
    if ~isempty(x2)
        y2=corr_fsc(x2);
        % Find point before value
        x1=find(corr_fsc(1:x2)>=fsc_points(i),1,'last');
        y1=corr_fsc(x1);

        % Slope
        m = (y2-y1)/(x2-x1);

        % Find X-value
        x_val = ((fsc_points(i)-y1)/m)+x1;

        % Write out resolution
        fsc_values(i) = (size(refA,1)*pixelsize)/x_val;

        % Display output
        disp(['FSC at ',num2str(fsc_points(i)),' = ',num2str(fsc_values(i),'%.1f'),' Angstroms.']);
    end
    
end



%% Filtering

if ~isempty(ref_avg_name) && ~strcmp(ref_avg_name,'none')
    
    % Initialize 1D filter
    filt_1d = ones(1,boxsize/2);
    
    % Calculate FOM
    if apply_fom == 1
        Cref = real(sqrt((2.*abs(corr_fsc))./(1+abs(corr_fsc))));   % 1D filter
        filt_1d = filt_1d.*Cref;   % Calculate 3D filter
    end

    % Calcualte sharpening filter
    if bfactor ~= 0
        % Calculate 1D frequency array
        freq_1d = 1:boxsize/2;
        freq_1d = (boxsize*pixelsize)./freq_1d;
        % Calculate sharpening filter
        exp_filt = exp(-(bfactor./(4.*(freq_1d.^2))));
        filt_1d = filt_1d.*exp_filt;
    end
    
    % Determine threhold in Fourier pixels
    cut_idx = find(corr_fsc(2:end)<=fsc_thresh,1)+1;
    % Set lowpass
    filt_1d(cut_idx:end) = 0;
    
    % Generate 3D filter
    filter = tom_sph2cart(repmat(filt_1d',[1, (boxsize*2), (boxsize)]));
    
    % Average reverence
    ref_avg = (refA+refB)./2;
    
    % Box edge mask
    if edge_smooth > 0
        box_mask = zeros(boxsize,boxsize,boxsize);
        b1 = (2*edge_smooth)+1;
        b2 = boxsize - (2*edge_smooth);
        box_mask(b1:b2,b1:b2,b1:b2) = 1;
        box_mask = smooth3(box_mask,'gaussian',edge_smooth, edge_smooth);
        ref_avg = ref_avg.*box_mask;
    end

        
    
    % Apply filter to average
    ft_avg = fftn(ref_avg);
    filt_ref = real(ifftn(ft_avg.*ifftshift(filter)));
    
    % Flip density
    if flip_density == 1
        filt_ref = filt_ref.*-1;
    end

    % Write output
    sg_mrcwrite(ref_avg_name,filt_ref,[],'pixelsize',pixelsize);
    
    if plot_filt == 1
        figure
        plot(filt_1d);
    end
    
end













