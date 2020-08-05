function o = check_motl_for_subtomo(p,o,s,idx)
%% check_motl_for_subtomo
% Check loaded motivelist for compatability for current subtomogram
% averaging run.
%
% WW 06-2019

%% Check check

% Parse mode
mode = strsplit(p(idx).subtomo_mode,'_');

% Check case
switch mode{2}
    
    case 'singleref'
        
        if o.motl_type == 3
            error([s.nn,'ACHTUNG!!! Invalid motivelist type!!! Multi-entry motivelist cannot be used in singleref run!!!']);
        end
        
    case 'multiclass'
        
        if o.motl_type == 3
            error([s.nn,'ACHTUNG!!! Invalid motivelist type!!! Multi-entry motivelist cannot be used in multiclass run!!!']);
        end
        
end


        
        

