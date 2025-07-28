function help_sg_calculate_FSC()
%% help_sg_calculate_FSC
% Print the help doumentation for sg_calculate_FSC.m
%
% WW 05-2024

%% Print help

fprintf('Notes on running sg_calculate_FSC: \n');
fprintf('Inputs need to be provided as name-value pairs (e.g. ''refA_name'', ''ref_A_1.mrc''") \n');
fprintf('If a default option is provided, it is not a required input. \n\n');




fprintf('Inputs for sg_calculate_FSC: \n');
fprintf('----------------------------\n\n');

fprintf('    * Reference names \n')
fprintf('        refA_name = Filename of reference A\n');
fprintf('        refB_name = Filename of reference B\n\n');

fprintf('    * FSC Mask name \n')
fprintf('        mask_name = Filename of FSC mask. If not provided, no mask will be used.\n\n');

fprintf('    * Volume parameters \n')
fprintf('        pixelsize = Pixel size of References in Angstroms \n\n');
fprintf('        symmetry = Symmetry of Reference. Default = C1\n');

fprintf('    * Output parameters \n')
fprintf('        ref_avg_name = Name of output filtered reference. Leave empty for no ouptut volume. \n');
fprintf('        flip_density = Flip density of output volume (1 = yes, 0 = no). Default = 1. \n\n');

fprintf('    * Filtering Parameters for Output Reference \n')
fprintf('        apply_fom = Apply Figure-of-Merit Weighting (1 = yes, 0 = no). Default = 1. \n');
fprintf('        bfactor = B-factor sharpening value. Default = 0. \n');
fprintf('        fsc_thresh = FSC-value for lowpass filter threshold. Default = 0.143. \n');
fprintf('        edge_smooth = Smooth box edge. 0 = off, otherwise odd number must be given. Default = 3. \n\n');

fprintf('    * Plotting Parameters \n')
fprintf('        x_label = X-axis  label as Fourier pixels (0) or real-space resolution (1). Default = 0. \n');
fprintf('        res_label = X-axis label resolutions (in Angstroms). Labels beyond Nyquist are ignored. Default = [32,16,8,6,4,2]. \n');
fprintf('        plot_diagnostic = Plot diagnostic plots the uncorrected, corrected, and mask FSC curves (1 = yes, 0 = no). Default = 0. \n');
fprintf('        plot_sharp = Plot sharpening filter (1 = yes, 0 = no). Default = 0. \n\n');


fprintf('    * FSC calculation options \n')
fprintf('        fourier_cutoff = Phase randomization cutoff resolution (in Fourier pixels). Default = 5. \n');
fprintf('        n_repeats = Number of repeats for phase-randomized FSC calculations. Default = 10. \n');


