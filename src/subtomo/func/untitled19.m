function ali = initialize_align_struct(o,motl)
halfset,subtomo_num,n_ref,n_ang,old_shifts)
%% initialize_align_struct
% Initialize an 'ali' struct to hold all angular search results.
%
% WW 10-2018

%% Check check
if nargin == 4
    old_shifts = [0,0,0];
end

%% Initialize struct

% Number of entries
n_entry = numel(motl.motl_idx);

% Initalize cell for ali arrays
ali_cell = cell(n_entry,1);

% Initialize array for each entry
for i = 1:n_entry
    
    % Initialize struct
    ali = repmat(struct('score',-2,'halfset',single(motl.halfset{i}-64),...
        'old_shift',[motl.x_shift(i),motl.y_shift(i),motl.z_shift(i)],...
        'new_shift',[0,0,0],...
        'phi',0,'psi',0,'the',0,...
        'class',motl.class(i)),o.n_ang,1);
    
    % Compose new euler angles
    for j = 1:o.n_ang
        
        
    end
end


% Initialize struct
% ali = struct();
ali(n_ang,n_ref).score = -2;

% Initial fields
fields = {'score',          -2;...
          'halfset',        int32(halfset);...
          'subtomo_num',    int32(subtomo_num);...
          'old_shift',      old_shifts;...
          'x_shift',        0;...
          'y_shift',        0;...
          'z_shift',        0;...
          'phi',            0;...
          'psi',            0;...
          'the',            0;...
          'class',          int32(0);...
          };
n_fields = size(fields,1);

% Fill fields
for i = 1:n_fields
    
    % Generate default value
    def_val = repmat(fields(i,2),[n_ang,n_ref]);
    
    % Store array
    [ali.(fields{i,1})] = def_val{:};
    
end
    
