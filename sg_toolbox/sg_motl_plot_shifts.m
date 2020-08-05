function sg_motl_plot_shifts(motl_name)
%% sg_motl_plot_shifts
% Plot X-, Y-, and Z-shifts as histograms in the reference frame. 
%
% WW 05-2019

%% Initialize

% Read motivelist
motl = sg_motl_read(motl_name);
n_motls = numel(motl);

% Parse shifts
shifts = cat(1,[motl.x_shift],[motl.y_shift],[motl.z_shift]);

% Initialize array for rotated shifts
r_shifts = zeros(3,n_motls);


%% Rotate shift vectors

for i = 1:n_motls
    
    % Generate rotation matrix
    rmat = sg_euler2matrix(-motl(i).psi,-motl(i).phi,-motl(i).the);
    
    % Shift vector
    r_shifts(:,i) = rmat*shifts(:,i);
    
end


%% Plot shifts
figure
histogram(r_shifts(1,:),100,'FaceColor','r');
    
figure
histogram(r_shifts(2,:),100,'FaceColor','g');

figure
histogram(r_shifts(3,:),100,'FaceColor','b');

