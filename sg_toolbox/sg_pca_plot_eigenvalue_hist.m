function sg_pca_plot_eigenvalue_hist(eigenval_name,grid_size,n_bins)
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

% Read data
data = csvread(eigenval_name);


% Determine plot dimensions
n_eig = size(data,2);
Y = cell(n_eig,1);
E = cell(n_eig,1);

for i = 1:n_eig
    [Y{i},E{i}] = histcounts(data(:,i),n_bins);
end

max_bin_size = ceil(max(reshape(cat(1,Y{:}),[],1))/50)*50;
max_edge = max(abs(reshape(cat(1,E{:}),[],1)));

%% Plot data

figure
for i = 1:n_eig
    subplot(grid_size(1),grid_size(2),i);
    hist(data(:,i),50);
    title(['Eigenvector ',num2str(i)]);
    axis ([-max_edge, max_edge, 0, max_bin_size ]);
end


