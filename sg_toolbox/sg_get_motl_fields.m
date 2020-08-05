function motl_fields = sg_get_motl_fields()
%% get_motl_fields
% A function to return stopgap motivelist fields and types.
%
% WW 06-2019

motl_fields = {'motl_idx', 'num', 'int';
               'tomo_num', 'num', 'int';
               'object', 'num', 'int';
               'subtomo_num', 'num', 'int';
               'halfset', 'str', 'str';
               'orig_x', 'num', 'float';
               'orig_y', 'num', 'float';
               'orig_z', 'num', 'float';
               'score', 'num', 'float';
               'x_shift', 'num', 'float';
               'y_shift', 'num', 'float';
               'z_shift', 'num', 'float';
               'phi', 'num', 'float';
               'psi', 'num', 'float';
               'the', 'num', 'float';
               'class', 'num', 'int'};
           
end
