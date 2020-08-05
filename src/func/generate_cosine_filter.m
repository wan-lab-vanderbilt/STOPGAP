function f = generate_cosine_filter(p,o,idx,f,mode)
%% generate_cosine_filter
% Calculate a filter for weighting slices by the cosine of their tilt
% angle. Areas where tilts overlap will be thresholded to a weight of 1.
%
% WW 07-2018

%% Check check

if strcmp(mode,'avg') && (o.avg_ss > 1)
    boxsize = o.ss_boxsize;
else
    boxsize = o.boxsize;
end


%% Generate filter

% Number of tilts
n_tilts = numel(o.wedgelist(f.wedge_idx).tilt_angle);

% Generate cosine filter
f.cos_filt = zeros(boxsize,'single');
for i = 1:n_tilts    
    temp_val = cosd(o.wedgelist(f.wedge_idx).tilt_angle(i)).^p(idx).cos_weight;
    temp_idx = temp_val > f.cos_filt(f.slice_idx{i});
	f.cos_filt(f.slice_idx{i}(temp_idx)) = temp_val;
end
% idx = f.cos_filt > 1;
% f.cos_filt(idx) = 1;

        
