function o = get_random_seed(p,o,s,idx)
%% get_random_seed
% Get random seed for a particular iteration. The seeds are used if random
% subsets are used or if random halfsets need to be generated. 
%
% WW 07-2018

%% Get random seed

% For subtomogram averaging
if isfield(p(idx),'subtomo_mode')
    mode = strsplit(p(idx).subtomo_mode,'_');
    switch mode{1}
        case 'ali'
            o.seed_idx = num2str(p(idx).iteration+1);
        case 'avg'
            o.seed_idx = num2str(p(idx).iteration);
    end
else
    o.seed_idx = num2str(p(idx).iteration);
end

% Read seed
o = read_random_seed(p,o,s,idx);

        
    
