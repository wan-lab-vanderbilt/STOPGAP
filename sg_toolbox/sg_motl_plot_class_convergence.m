function sg_motl_plot_class_convergence(motl_root,iteration_range)
%% sg_motl_plot_class_convergence
% Plot to number of motivelist entries that change class between
% iterations. 
%
% Inputs are the root of the motivelist name and a list of iterations. The
% iterations are assumed to be in order. 
%
% WW 06-2019

%% Intitialize

% Number of iterations
n_iter = numel(iteration_range);

% Class cell
class_cell = cell(n_iter,1);

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
            class_cell{i} = motl.class;
            
        case 3
            
            % Parse classes
            classes = unique(motl.class);
            n_classes = numel(classes);
            
            % Parse top scores
            [~,top_scores] = max(reshape(motl.scores,n_classes,[]),[],1);
            
            % Store classes
            class_cell{i} = classes(top_scores);      
            
    end
    
end

%% Determine class changes

% Number of class changes
n_changes = zeros(n_iter-1,1);

% Determine number of changes
for i = 2:n_iter
    
    n_changes(i-1) = sum(class_cell{i} ~= class_cell{i-1});
    
end


% Plot
figure
plot(iteration_range(2:end),n_changes)




    


    


    


    


    


    

