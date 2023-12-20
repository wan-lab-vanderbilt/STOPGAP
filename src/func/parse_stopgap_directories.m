function o = parse_stopgap_directories(p,o,s,idx,task)
%% 
% Parse directories for a given STOPGAP task. 
%
% WW 06-2023

%% Parse directories

switch task
    
    case 'subtomo'
        o = sg_parse_subtomo_directories(p,o,s,idx);
    case 'extract'
        o = sg_parse_extract_directories(p,o,s,idx);
    case 'tm'
        o = sg_parse_tm_directories(p,o,s,idx);
    case 'tps'
        o = sg_parse_tps_directories(p,o,s,idx);
end


