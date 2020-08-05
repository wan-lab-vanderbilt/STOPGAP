function check_empty_classes(p,o,s,idx)
%% check_empty_classes
% Check if a class emptied during averaging. If so, randomly reassing
% remaining members of the class.
%
% WW 08-2019

%% Check check

% Check for empty files
empty_name = ['emptyclass_',num2str(p(idx).iteration),'_'];
d = dir([p(idx).rootdir,'/',o.tempdir,'/',empty_name,'*']);
n_empty = numel(d);

% Emtpy classes
if n_empty > 0
    warning([s.nn,'ACHTUNG!!! ',num2str(n_empty),' classes emptied during iteration ',num2str(p(idx).iteration),'...']);
    
    % Parse empty class numbers
    empty_classes = zeros(n_empty,1);
    for i = 1:n_empty
        empty_classes(i) = str2double(d(i).name(numel(empty_name)+1:end));
    end
    
    % Remainig classes
    rem_class = setdiff(o.classes,empty_classes);
    n_rem = numel(rem_class);
    
    % Reassign classes
    for i = 1:n_empty
        
        % Emptied class index
        e_idx = o.allmotl.class == empty_classes(i);
        n_e = int32(sum(e_idx));
        
        % Randomly reassinged class
        reassign_class = rem_class(ceil(rand(1,n_e).*n_rem));
        o.allmotl.class(e_idx) = reassign_class;
        
    end
    
    % Write new motl
    sg_motl_write2([p(idx).rootdir,'/',o.listdir,'/',p(idx).motl_name,'_',num2str(p(idx).iteration+1),'.star'],o.allmotl);

    disp([s.nn,'Revised motivelist written!!!']);
    
end

        


