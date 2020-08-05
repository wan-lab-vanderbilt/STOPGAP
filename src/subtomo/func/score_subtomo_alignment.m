function [o,v,ali] = score_subtomo_alignment(p,o,s,idx,v,score_mode,f,ali)
%% score_subtomo_alignment
% A function to scoring matches between subtomograms. This function allows
% for different types of scoring functions to be used, as defined in the
% 'p' struct. Since different scoring schemes require different types of
% preparations of the volumes, this function can also prepare the volumes.
%
% Mode 'prep' prepares volumes, while mode 'score' scores an alignment. 
%
% Some modes may also have an 'init' mode, which initializes basic
% parameters that do not change per run.
% 
% Currently supported scoring methods are 'flcf' for the Roseman fast local
% correlation function (FLCF) and 'pearson' for real-space Pearson 
% correlation with explicitly refined shifts. Any 'laplacian' function
% applies the laplacian transform to subtomograms prior to scoring.
%
% WW 06-2019


%% Initialize

% Check inputs
if nargin == 7
    ali = struct();
elseif nargin ~= 8
    error([s.nn,'ACHTUNG!!! Invalid number of inputs for score_subtomo_match!!!']);
end

% Check mode
if ~any(strcmp(score_mode,{'init','prep','score'}));
    error([s.nn,'ACHTUNG!!! Invalid mode for score_subtomo_match!!!']);
end

% Parse scoring function
if isfield(p(idx),'scoring_fcn')
    func = p(idx).scoring_fcn;
else
    func = 'flcf';
end

%% Score!!!

switch func               
                
    % Pearson correlation
    case 'pearson'
        [o,v,ali] = pearson_subtomo_scoring_function(p,o,s,idx,v,f,score_mode,ali);
        
    % Fast local correlation function
    case 'flcf'
        [o,v,ali] = flcf_subtomo_scoring_function(p,o,s,idx,v,f,score_mode,ali);

                
end



