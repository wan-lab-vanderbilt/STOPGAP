function fid = sg_fwrite_mrcheader(fid,header)
%% sg_fwrite_mrcheader
% Write a .mrc header to an open file.
%
% WW 06-2018

%% Parse labels

% Full label array
label = char(zeros(800,1));

% Parse labels from cell
for i = 1:header.nlabl
    
    % Start index of label
    s_idx = ((i-1)*80)+1;
    
    % Truncate label to 80 characters
    if numel(header.labl{i}) > 80
        header.labl{i} = header.labl{i}(1:80);
    end
    
    % Store label
    label(s_idx:s_idx+numel(header.labl{i})-1) = header.labl{i};
    
end

%% Write header

fwrite(fid,header.nx,'int');           %integer: 4 bytes
fwrite(fid,header.ny,'int');           %integer: 4 bytes
fwrite(fid,header.nz,'int');           %integer: 4 bytes
fwrite(fid,header.mode,'int');         %integer: 4 bytes
fwrite(fid,header.nxstart,'int');      %integer: 4 bytes
fwrite(fid,header.nystart,'int');      %integer: 4 bytes
fwrite(fid,header.nzstart,'int');      %integer: 4 bytes
fwrite(fid,header.mx,'int');           %integer: 4 bytes
fwrite(fid,header.my,'int');           %integer: 4 bytes
fwrite(fid,header.mz,'int');           %integer: 4 bytes
fwrite(fid,header.xlen,'float');       %float: 4 bytes
fwrite(fid,header.ylen,'float');       %float: 4 bytes
fwrite(fid,header.zlen,'float');       %float: 4 bytes
fwrite(fid,header.alpha,'float');      %float: 4 bytes
fwrite(fid,header.beta,'float');       %float: 4 bytes
fwrite(fid,header.gamma,'float');      %float: 4 bytes
fwrite(fid,header.mapc,'int');         %integer: 4 bytes
fwrite(fid,header.mapr,'int');         %integer: 4 bytes
fwrite(fid,header.maps,'int');         %integer: 4 bytes
fwrite(fid,header.amin,'float');       %float: 4 bytes
fwrite(fid,header.amax,'float');       %float: 4 bytes
fwrite(fid,header.amean,'float');      %float: 4 bytes
fwrite(fid,header.ispg,'short');       %integer: 2 bytes
fwrite(fid,header.nsymbt,'short');     %integer: 2 bytes
fwrite(fid,header.next,'int');         %integer: 4 bytes
fwrite(fid,header.creatid,'short');    %integer: 2 bytes
fwrite(fid,zeros(30,1),'char');        % Unused data: 30 bytes
fwrite(fid,header.nint,'short');       %integer: 2 bytes
fwrite(fid,header.nreal,'short');      %integer: 2 bytes
fwrite(fid,zeros(28,1),'char');        % Unused data: 28 bytes
fwrite(fid,header.idtype,'short');     %integer: 2 bytes
fwrite(fid,header.lens,'short');       %integer: 2 bytes
fwrite(fid,header.nd1,'short');        %integer: 2 bytes
fwrite(fid,header.nd2,'short');        %integer: 2 bytes
fwrite(fid,header.vd1,'short');        %integer: 2 bytes
fwrite(fid,header.vd2,'short');        %integer: 2 bytes
fwrite(fid,header.tiltangles,'float'); %float: 6*4 bytes=24 bytes
fwrite(fid,header.xorg,'float');       %float: 4 bytes
fwrite(fid,header.yorg,'float');       %float: 4 bytes
fwrite(fid,header.zorg,'float');       %float: 4 bytes
fwrite(fid,header.cmap,'char');        %Character: 4 bytes
fwrite(fid,header.stamp,'char');       %Character: 4 bytes
fwrite(fid,header.rms,'float');        %float: 4 bytes
fwrite(fid,header.nlabl,'int');        %integer: 4 bytes
fwrite(fid,label,'char');        %Character: 800 bytes



