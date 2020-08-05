function header = sg_append_mrc_label(header,new_label)
%% 
% A function to append a 80 character label to a .mrc header. If the label
% is too long, it is automatically truncated down.
%
% If there are more than 10 label lines, the first label is cleared to make
% space for the appended label.
%
% WW 06-2018

%% Append label

% Check label length
if numel(new_label) > 80
    new_label = new_label(1:80);
end

% Append label
header.labl = cat(1,header.labl,{new_label});

% Check lengths
switch header.nlabl
    case 10
        header.labl = header.labl(2:11);
    otherwise
        header.nlabl = header.nlabl+1;
end


