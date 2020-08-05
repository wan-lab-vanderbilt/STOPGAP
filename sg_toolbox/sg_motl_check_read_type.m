function read_type = sg_motl_check_read_type(motl)
%% sg_motl_check_read_type
% Check if a motivelist has been read in type 1 or type 2 formatting.
%
% WW 09-2019

%% Check check

% Determine class of halfset
h_class =  class(motl(1).halfset);

% Return type
switch h_class
    case 'char'
        read_type = 1;
    case 'cell'
        read_type = 2;
    otherwise
        error('ACHUTNG!!! Unsuppored motivelist read-type!!!');
end


