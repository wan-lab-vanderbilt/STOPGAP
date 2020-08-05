function sg_motl_plot_class_bar_graph(motl)
%% sg_motl_plot_class__bar_graph
% Plot bar graph of class occupancies.
%
% WW 06-2019

%% Check check

% Read motl
if ischar(motl)
    motl = sg_motl_read2(motl);
end
n_motls = numel(motl.motl_idx);

%% Plot!!!

% Parse classes
classes = unique([motl.class]);
n_classes = numel(classes);

% Determine occupancies
class_occ = zeros(size(classes));
for i = 1:n_classes
    class_occ(i) = sum([motl.class] == classes(i));
end

figure;
bar(classes,class_occ);

for i = 1:n_classes
    disp(['Class ',num2str(classes(i)),': ',num2str(class_occ(i)),' particles (',num2str((class_occ(i)/n_motls)*100,'%.2f'),'%)']);
end

