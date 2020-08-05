function sg_motl_rescale(input_name,output_name,scale_factor,renumber)
%% sg_motl_rescale
% A function to rescale a motivelist by a given input factor. Shifts are 
% applied to the original positions, making the motivelist ready for 
% extraction. Center pixels are preserved as (floor(boxsize/2)+1).
%
% WW 08-2018

%% Check check

if nargin == 3
    renumber = false;
elseif nargin ~= 4
    error('ACHTUNG!!! Incorrect number of inputs!!!');
end



%% Initialize

% Read input motl
allmotl = sg_motl_read2(input_name);


% Renumber
if renumber
    
    % Check type
    motl_type = sg_motl_check_type(allmotl,2);

    % Renubmer based on type
    switch motl_type
        case {1,2}
            % Renumber in order
            allmotl.motl_idx = int32((1:numel(allmotl.motl_idx))');
            allmotl.subtomo_num = allmotl.motl_idx;
        case 3
            % Determine number of classes
            n_classes = numel(unique(allmotl.class));
            % Determine number of entries
            n_motl = numel(allmotl.classes)/n_classes;

            % Fill indices and subtomo numbers
            allmotl.motl_idx = int32(reshape(repmat(1:n_motl,n_classes,1),[],1));
            allmotl.subtomo_num = allmotl.motl_idx;
    end
end      

% Origin fields
o_fields = {'orig_x','orig_y','orig_z'};
% Shift fields
s_fields = {'x_shift','y_shift','z_shift'};


%% Rescale!!!

% Rescale
for i = 1:3
    
    % Apply shift
    new_pos = allmotl.(o_fields{i}) + allmotl.(s_fields{i});

    % Rescale values
    if scale_factor > 1
        new_pos = (new_pos.*scale_factor) - (scale_factor-1);
    else
        new_pos = new_pos.*scale_factor;
    end
    
    % Rounded positions and shifts
    pos = round(new_pos);
    shift = pos - new_pos;
    
    % Store values
    allmotl.(o_fields{i}) = pos;
    allmotl.(s_fields{i}) = shift;    
    
    
end


% Write output
sg_motl_write2(output_name,allmotl);
    
    


