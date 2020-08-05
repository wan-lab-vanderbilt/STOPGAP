function sg_motl_plot_class_occupancies(motl_root,iteration_range)
%% sg_motl_plot_class_occupancies
% Plot the occupancies of each class over time.
%
% Inputs are the root of the motivelist name and a list of iterations. The
% iterations are assumed to be in order. 
%
% WW 06-2019

%% Intitialize

% Read first motivelist
motl = sg_motl_read2([motl_root,'_',num2str(iteration_range(1)),'.star']);

% Determine classe
classes = unique(motl.class);
n_classes = numel(classes);

% Number of iterations
n_iter = numel(iteration_range);

% Class cell
class_counts = zeros(n_classes,n_iter);


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
            
            % Count classes of initial motl
            for j = 1:n_classes
                class_counts(j,i) = sum(motl.class==classes(j));
            end
            
            
        case 3
                       
            % Parse top scores
            [~,top_scores] = max(reshape(motl.scores,n_classes,[]),[],1);
            
            % Get top classes
            top_classes = classes(top_scores);      
            
            % Count classes of initial motl
            for j = 1:n_classes
                class_counts(j,i) = sum(top_classes==classes(j));
            end
    end
    
end

%% Plot figures

% Plot
figure
hold on
for j = 1:n_classes
    plot(iteration_range,class_counts(j,:))
end




    


    


    


    


    


    

