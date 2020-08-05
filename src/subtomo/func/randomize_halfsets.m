function o = randomize_halfsets(o)
%% randomize_halfsets
% A function to randomize the halfsets of a motivelist between A and B.
%
% The randomizer is seeded based on alignment parameters in the motive
% list, producing a pseudo-randomization that can be repeated.
%
% WW 05-2018

%% Randomize!!!

% Generate halfset array
ab_array = repmat({'A';'B'},[ceil(o.n_motls/2),1]);

% Generate random seed
rng(round(o.rseed/2),'twister');    
rand_idx = randperm(numel(ab_array));

o.rand_halfset = cat(2,num2cell(unique(o.motl_idx)),ab_array(rand_idx(1:o.n_motls)));


