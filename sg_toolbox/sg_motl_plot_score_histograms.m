function sg_motl_plot_score_histograms(motl_name,motl_range,grid_size,n_bins)
%% sg_pca_plot_eigenvalue_hist
% Plot eigenvalues as histograms in a grid plot. Eigenvalues are input as
% .csv files with each column containing the values for one eigenvector. 
%
% The grid is determined by the input grid size and binned into the input
% number of bins.
%
% WW 08-2019

%% Check check

if numel(grid_size) ~= 2
    error('ACTHUNG!!! Grid size is a 2D vector!!!');
end


%% Initialize

% Number of motivelists
n_motls = numel(motl_range);

% Load scores
scores = cell(n_motls,1);
for i = 1:n_motls
    name = [motl_name,'_',num2str(motl_range(i)),'.star'];
    motl = sg_motl_read2(name);
    scores{i} = motl.score;
end
clear motl



% Determine plot dimensions
Y = cell(n_motls,1);
E = cell(n_motls,1);

for i = 1:n_motls
    [Y{i},E{i}] = histcounts(scores{i},n_bins);
end

max_bin_size = ceil(max(reshape(cat(1,Y{:}),[],1))/50)*50;
max_edge = max(abs(reshape(cat(1,E{:}),[],1)));

%% Plot data

figure
for i = 1:n_motls
    subplot(grid_size(1),grid_size(2),i);
    hist(scores{i},50);
    title(['Iteration ',num2str(motl_range(i))]);
    axis ([-max_edge, max_edge, 0, max_bin_size ]);
end


