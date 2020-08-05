function ordered_fields = sg_get_ordered_vmap_input_fields()
%% get_ordered_vmap_input_fields
% Get ordered fields for variance map .star.
%
% WW 05-2019


%% Get fields
ordered_fields = {'completed_p_vmap', 'boo';
                  'completed_f_vmap', 'boo';
                  'iteration', 'num';
                  'vmap_mode', 'str';
                  'rootdir', 'str';
                  'tempdir', 'str';
                  'commdir', 'str';
                  'rawdir',  'str';
                  'refdir',  'str';
                  'maskdir',  'str';
                  'listdir',  'str';
                  'subtomodir', 'str';
                  'metadir', 'str';
                  'motl_name', 'str';
                  'wedgelist_name', 'str';
                  'binning', 'num';
                  'ref_name', 'str';
                  'vmap_name', 'str';
                  'subtomo_name', 'str';
                  'mask_name', 'str';
                  'lp_rad', 'num';
                  'lp_sigma', 'num';
                  'hp_rad', 'num';
                  'hp_sigma', 'num';
                  'symmetry', 'str';
                  'score_thresh', 'num';
                  'fthresh', 'num';
                  };
