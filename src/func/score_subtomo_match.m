function [o,v,ali] = score_subtomo_match(p,idx,o,v,mode,f,ali)
%% score_subtomo_match
% A function to scoring matches between subtomograms. This function allows
% for different types of scoring functions to be used, as defined in the
% 'p' struct. Since different scoring schemes require different types of
% preparations of the volumes, this function can also prepare the volumes. 
% Mode 'prep' prepares volumes, while mode 'score' scores an alignment. 
% Some modes may also have an 'init' mode, which initializes basic
% parameters that do not change per run.
% 
% Currently supported scoring methods are 'flcf' and 'flcf_weighted',
% for the Roseman fast local correlation function (FLCF), 'pearson' for
% real-space Pearson correlation with explicitly refined shifts.
%
% WW 04-2018


%% Initialize

% Check inputs
if nargin == 6
    ali = struct();
elseif nargin ~= 7
    error('ACHTUNG!!! Invalid number of inputs for score_subtomo_match!!!');
end

% Check mode
if ~any(strcmp(mode,{'init','prep','score'}));
    error('ACHTUNG!!! Invalid mode for score_subtomo_match!!!');
end

% Parse scoring function
if isfield(p(idx),'scoring')
    func = p(idx).scoring;
else
    func = 'flcf';
end

%% Score!!!

switch func               
                
    % Pearson correlation
    case 'pearson'
        [o,v,ali] = pearson_scoring_function(o,v,mode,f,ali);
        
    case {'flcf','flcf_weighted'}
        [o,v,ali] = flcf_scoring_function(o,v,mode,func,f,ali);

                
end




