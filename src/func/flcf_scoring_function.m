function [o,v,ali] = flcf_scoring_function(o,v,mode,func,f,ali)
%% flcf_scoring_function
% A functon for initializing, preparing, and performing the Roseman
% fast local correlation function (FLCF).
%
% WW 04-2018
global nn

switch mode
    
    case 'init'
    
    case 'prep'
        
        % Fourier transform particle
        v.fsubtomo = fftn(v.subtomo);
        % Apply filter
        v.fsubtomo = v.fsubtomo.*f.pfilt.*o.bandpass;
        % Set 0-frequency peak to zero
        v.fsubtomo(1,1,1) = 0;


        % Store complex conjugate
        v.conjSubtomo = conj(v.fsubtomo); 
        % Filtered particle
        filt_subtomo = ifftn(v.fsubtomo);
        % Store complex conjugate of square
        v.conjSubtomo2 = conj(fftn(filt_subtomo.^2));
        
        % Store conjugates for applying alignment filter
        if isfield(o,'ali_filt')
            v.conjSubtomo_unfilt = v.conjSubtomo;
            v.conjSubtomo2_unfilt = v.conjSubtomo2;
        end
    
        
    case 'score'

        % Rotate the reference
        rotRef = tom_rotate(o.ref{v.ref_num},[ali.phi,ali.psi,ali.the]);

        % Rotate mask
        rotMask = tom_rotate(o.mask,[ali.phi,ali.psi,ali.the]);
        % Binarize mask
        if strcmp(func,'flcf')
            rotMask = double(rotMask>=0.5);
        end
            
        

        % Calculate shifted fourier transform of rotated reference
        fref = fftn(rotRef);
        % Apply bandpass filtered wedge and edge mask, then invert fftshift
        fref = fref.*f.rfilt.*o.bandpass;
        % Set 0-frequency to zero
        fref(1,1,1) = 0;
        % Apply alignment filter
        if isfield(o,'ali_filt')
            r_ali_filt = ifftshift(tom_rotate(o.ali_filt,[ali.phi,ali.psi,ali.the]));
            fref = fref.*r_ali_filt;
            v.conjSubtomo = v.conjSubtomo_unfilt.*r_ali_filt;
            v.conjSubtomo2 = v.conjSubtomo2_unfilt.*r_ali_filt;
        end

        % Inverse transform particle
        rotRef = ifftn(fref);

        % Normalize reference under mask
        mRef = normalize_under_mask(rotRef,rotMask);                                

        % Calculate FLCF
        scoring_map = calculate_flcl(mRef,rotMask,v.conjSubtomo,v.conjSubtomo2);

        % Rotate CC mask
        rccmask = tom_rotate(o.ccmask,[ali.phi,ali.psi,ali.the]);

        % Find ccc peak
        [pos, score] = find_subpixel_peak(scoring_map, rccmask);
        shift = pos-o.cen;  % Shift from center of box

        % For optimal score, update parameters
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
