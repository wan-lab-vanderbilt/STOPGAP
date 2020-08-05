function fields = get_fields()
%% get_fields
% Return parameter fields and types for subtomogram extraction.
%
% WW 08-2018

%% Fields


fields = {'rootdir',            'str', 'req', [];
          'motl_dir',           'str', 'req', 'lists/';
          'motl_name',          'str', 'req', [];
          'tomo_dir',           'str', 'req', [];
          'tomo_digits',        'num', 'req', '1';
          'subtomo_dir',        'str', 'req', 'subtomograms/';
          'subtomo_name',       'str', 'req', [];
          'subtomo_digits',     'num', 'req', '1';
          'format',             'str', 'req', 'mrc8';
          'boxsize',            'num', 'req', [];
          'pixelsize',          'num', 'req', [];
          'output_pixelsize',   'num', 'nrq', [];
          'comm_dir',           'str', 'req', 'comm/';
          'stats_dir',          'str', 'req', 'raw/';
          'n_cores',            'num', 'req', []};
      
      