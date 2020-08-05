tomo_dims = floor([o.wedgelist(f.wedge_idx).tomo_x;o.wedgelist(f.wedge_idx).tomo_y;o.wedgelist(f.wedge_idx).tomo_z]./p(idx).binning);
tomo_cen = floor(tomo_dims/2)+1;
tomo_cen(3) = tomo_cen(3)- (o.wedgelist(f.wedge_idx).z_shift./p(idx).binning);


% x = motl.orig_x + motl.x_shift - tomo_cen(1);
% z = motl.orig_z + motl.z_shift - tomo_cen(3);

pos = zeros(3,sum(tomo_idx));
pos(1,:) = o.allmotl.orig_x(tomo_idx) + o.allmotl.x_shift(tomo_idx) - tomo_cen(1);
pos(2,:) = o.allmotl.orig_y(tomo_idx) + o.allmotl.y_shift(tomo_idx) - tomo_cen(2);
pos(3,:) = o.allmotl.orig_z(tomo_idx) + o.allmotl.z_shift(tomo_idx) - tomo_cen(3);

% Calculate rotation matrix
q = sg_axisangle2quaternion([0,1,0],-60);
rmat = sg_quaternion2matrix(q);

% Rotate positions
r_pos = rmat*pos;
    
% figure
scatter(r_pos(1,:),r_pos(2,:));
hold on
% scatter(x,z);

mean_x = mean(r_pos(1,:));
mean_z = mean(r_pos(3,:));

scatter(mean_x,mean_z,'rx');
% set(gca, 'yTick', [min(r_pos(3,:)), mean_z, max(r_pos(3,:))]);

disp(['cen: (',num2str(mean_x),',',num2str(mean_z),')']);

z_offset = r_pos(1,1) - mean_z;

disp(['mean z: ',num2str(mean_z)]);
disp(['z_offset: ',num2str(z_offset)]);
