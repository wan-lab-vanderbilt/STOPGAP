function o = prepare_matchlist(p,o,s,idx)
%% prepare_matchlist
% Calculate a list of matches to be performed between tiles and 
% orientations. 
%
% WW 09-2024

%% Prepare match list

% Initialize match list
total_ang = sum(o.n_ang);               % In case of multi-template matching
o.n_matches = o.n_tiles*total_ang;
o.matchlist = zeros(o.n_matches,3);     % tile_idx, tmpl_idx, ang_idx

% Fill match list
c1 = 1;     % Counter for tiles
c2 = 1;     % Counter for angles
for i  = 1:o.n_tiles
    
    % Calculate indices for current tile
    e1 = c1 + total_ang - 1;
    
    % Fill tile indices
    o.matchlist(c1:e1,1) = i;
    
    % Increment counter
    c1 = c1 + total_ang;
    
    
    % Fill template and angle indices
    for j = 1:o.n_tmpl
        
        % Calculate indices for current template
        e2 = c2 + o.n_ang(j) - 1;
        
        % Fill template indices
        o.matchlist(c2:e2,2) = j;
        
        % Fill angle indices
        o.matchlist(c2:e2,3) = 1:o.n_ang(j);
        
        % Increment counter
        c2 = c2 + o.n_ang(j);
        
    end
end




% Write matchlist to comm_dir
if o.procnum == 1
    matchlist_name = ['tm_matchlist_',num2str(p(idx).tomo_num),'.csv'];
    dlmwrite([p(idx).rootdir,o.commdir,matchlist_name,'_temp'],o.n_matches,'precision','%12i');
    system(['mv ',p(idx).rootdir,o.commdir,matchlist_name,'_temp ',p(idx).rootdir,o.commdir,matchlist_name]);   % Prevent read error during writing
end


% Calculate number of packets
o.n_packets = o.n_cores*s.packets_per_core;



