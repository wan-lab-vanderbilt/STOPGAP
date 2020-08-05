function sg_wedgelist_write(wedgelistname,wedgelist)
%% write_wedgelist
% A function for writing a stopgap wedgelist. The function insures proper
% formatting of wedgelists.
%
% WW 06-2018

%% Check check!!!

% Get fields
fields = sg_get_wedgelist_fields;

% Check fields
keep = true(size(fields,1),1);
w_fields = fieldnames(wedgelist);
for i = 1:size(fields,1)
    if ~any(strcmp(fields{i},w_fields))
        keep(i) = false;
    end    
end
fields = fields(keep,:);

% Sort wedgelist fields
wedgelist = orderfields(wedgelist,fields(:,1));

%% Expand wedgelist

if numel(wedgelist(1).tilt_angle) > 1
    
    % Initialize wedgelist cell
    n_tomos = numel(wedgelist);
    w_cell = cell(n_tomos,1);
    
    for i = 1:n_tomos
        n_tilts = numel(wedgelist(i).tilt_angle);
        temp_w = repmat(wedgelist(i),[n_tilts,1]);
        array_fields = {'tilt_angle','exposure','defocus','defocus1','defocus2','astig_ang','pshift'};
        for j = 1:numel(array_fields)
            if any(strcmp(fields(:,1),array_fields{j}))
                array_cell = num2cell([temp_w(1).(array_fields{j})]);
                [temp_w.(array_fields{j})] = array_cell{:};
            end
        end
        w_cell{i} = temp_w;
    end
    
    wedgelist = cat(1,w_cell{:})';
end

    

%% Write output

stopgap_star_write(wedgelist,wedgelistname,'stopgap_wedgelist',[],4,2);


