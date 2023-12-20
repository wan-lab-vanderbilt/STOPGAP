function o = tm_get_total_angles(p,o,s,idx)
%% tm_get_total_angles
% A function to determine the total number of angles to match.
%
% WW 04-2021



%% Read template list

% Read template list
o.tlist = sg_tm_template_list_read([p(idx).rootdir,'/',o.listdir,'/',p(idx).tlist_name]);
o.n_tmpl = numel(o.tlist);




%% Read angles


% Initialize cell arrays
o.ang = cell(o.n_tmpl,1);
o.n_ang = zeros(o.n_tmpl,1);

% Read angles
for i = 1:o.n_tmpl
    
    % Parse anglelist name
    ang_name = [o.listdir,o.tlist(i).anglist_name];
    
    
    % Read angle list
    try
        o.ang{i} = csvread([p(idx).rootdir,ang_name])';
    catch
        error([s.cn,'ACHTUNG!!! Error reading angle list!!!']);
    end
    o.n_ang(i) = size(o.ang{i},2);
    
end

% Total number of angles
o.tot_ang = sum(o.n_ang);                


