function f = score_based_weighting(p,idx,o,f,motl,mode)
%% score_based_weighting
% Calculate score-based weighting for generating averages. Subtomograms are
% weighted by an exponential frequency weighting factor; signal dapenning
% is higher for lower scores.
%
% The scores are weighted for each class in each tomogram.
%
% WW 08-2018


%% Calculate filters

switch mode
    
    % Initialize filter
    case 'init'
        
        % Parse score indices
        t_idx = find(o.tomos == f.tomo);
        c_idx = find(o.classes == f.class);
        
        % Calculate weighting factor     
        f.sbw_maxs = f.score_array(t_idx,c_idx,1);
        f.sbw_mins = f.score_array(t_idx,c_idx,2);
        if f.sbw_mins < 0
            f.sbw_mins = 0;
        end
        f.sbw_wf = calculate_score_based_weighting_factor(o.unbinned_pixelsize,p(idx).score_weight,f.sbw_mins,f.sbw_maxs);
        if abs(f.sbw_wf) == Inf
            f.sbw_wf = 0;
        end
        
        f.sbw_fun = @(score) exp(f.sbw_wf.*(f.sbw_maxs - score).*(f.freq_array.^2));
        
        
    case 'calc'
        
        % Calcualte new filter
        f.sbw_filt = f.sbw_fun(max(motl.score));
        
end
        



