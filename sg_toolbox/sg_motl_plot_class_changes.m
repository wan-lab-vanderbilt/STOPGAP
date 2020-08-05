function sg_motl_plot_class_changes(motl_root,iteration_range)
%% sg_motl_plot_class_changes
% Calculate the percentage of subtomograms that have changed class through 
% the range.
%
% WW 06-2019

%% Intitialize

% Read first motivelist
motl = sg_motl_read2([motl_root,'_',num2str(iteration_range(1)),'.star']);
n_motls = numel(unique(motl.motl_idx));

% Number of iterations
n_iter = numel(iteration_range);

% Class cell
class_array = zeros(n_motls,n_iter);

%% Parse classes

% Loop through iterations
for i = 1:n_iter
    
    % Read motivelist
    motl = sg_motl_read2([motl_root,'_',num2str(iteration_range(i)),'.star']);
    
    % Check type
    motl_type = sg_motl_check_type(motl);
    
    % Parse classes
    switch motl_type
        case {1,2}
            class_array(:,i) = motl.class;
            
        case 3
            
            % Parse classes
            classes = unique(motl.class);
            n_classes = numel(classes);
            
            % Parse top scores
            [~,top_scores] = max(reshape(motl.scores,n_classes,[]),[],1);
            
            % Store classes
            class_array(:,i) = classes(top_scores);      
            
    end
    
end

%% Determine class changes

% Class changes
class_changes = zeros(n_motls,1);

% Determine number of changes
for i = 2:n_iter
    change_idx = class_array(:,i-1) ~= class_array(:,i);
    class_changes = class_changes + change_idx;
end

% Unchanged
no_changes = sum(class_changes == 0);
disp(['Subtomos with unchanged classes: ',num2str(no_changes)]);

% Plot bar graph
[N,~] = histcounts(class_changes,0:max(class_changes)+1);
figure
bar(0:max(class_changes),N);

    


    


    


    


    

