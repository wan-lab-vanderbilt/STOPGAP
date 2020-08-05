function motl = sort_motl(motl)
%% sort_motl
% A function to sort a motl struct array. The proper soring is to sort
% first by the subtomo_num, then by the class.
%
% WW 05-2018

%% Sort!!!

% Parse subtomo_num and class
sort_array = zeros(numel(motl),2);
sort_array(:,1) = [motl.subtomo_num];
sort_array(:,2) = [motl.class];

% Get sorting index
[~,sort_idx] = sortrows(sort_array,[1,2]);

% Sort motl
motl = motl(sort_idx);

