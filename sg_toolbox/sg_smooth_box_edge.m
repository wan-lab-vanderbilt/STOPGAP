function masked_vol = sg_smooth_box_edge(vol,edge_smooth)

boxsize = size(vol,1);
box_mask = zeros(boxsize,boxsize,boxsize);
b1 = (2*edge_smooth)+1;
b2 = boxsize - (2*edge_smooth);
box_mask(b1:b2,b1:b2,b1:b2) = 1;
box_mask = smooth3(box_mask,'gaussian',edge_smooth, edge_smooth);
masked_vol = vol.*box_mask;