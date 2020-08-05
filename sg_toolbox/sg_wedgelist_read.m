function wedgelist = sg_wedgelist_read(wedgelistname,mode)
%% sg_wedgelist_read
% Read in stopgap formatted wedgelist.
%
% Depending on mode, wedgelist can be returned as normal struct array 
% ('full') or condensed into a more usable format ('compact').
%
% WW 05-2018

%% Read wedgelist

if nargin == 1 
    mode = 'compact';
end
    

% Read .star file
try
    w_temp = stopgap_star_read(wedgelistname, false, [], 'stopgap_wedgelist');
catch
    error(['ACHTUNG!!! Error reading ',wedgelistname,'!!!']);
end

% Evaluate field types
field_types = get_wedgelist_fields;
w = evaluate_field_types(w_temp, field_types);


%% Check for defocus type

% Parse fields from wedgelist
w_fields = fieldnames(w);


%% Parse wedgelist

switch mode
    
    case 'full'
        wedgelist = w;
        
    case 'compact'
        % Determine number of tomograms
        tomos = unique([w.tomo_num]);
        n_tomos = numel(tomos);
        
        % Initialize wedgelist
        wedgelist(n_tomos).tomo_num = [];
        
        % Parse parameters per tomogram
        for i = 1:n_tomos
            
            % Find entries for tomogram
            idx = find([w.tomo_num]==tomos(i));     
            
            for j = 1:numel(w_fields)
                
                % Determine field type
                type_idx = strcmp(w_fields{j},field_types(:,1));
                type = field_types{type_idx,3};
                
                % Fill field based on single values or arrays
                switch type
                    case 'single'
                        wedgelist(i).(w_fields{j}) = w(idx(1)).(w_fields{j});
                    case 'array'
                        wedgelist(i).(w_fields{j}) = [w(idx).(w_fields{j})]';
                end
            end
            
            if all(isfield(w,{'defocus1','defocus2','astig_ang'}))
                wedgelist(i).defocus = cat(2,[w(idx).defocus1]',[w(idx).defocus2]',[w(idx).astig_ang]');
            end
        end
end




