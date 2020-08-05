function issue_fthresh_warning(rootdir,warn_name,d_range,fthresh)
%% issue_fthresh_warning
% Write warning out to a file about the reference dynamic range being
% outside of the Fourier threshold.
%
% WW 11-2018

%% Warning!!!

% Warning name


% Open file 
fthresh_warn = fopen([rootdir,'/',warn_name],'w');


% Write threshold    
fprintf(fthresh_warn,'%s\n',['ACHTUNG!!! Fourier space dynamic range is ',num2str(d_range,'%.2f'),'.']);
fprintf(fthresh_warn,'%s\n',['This has been thresholded to your desired threshold of ',num2str(fthresh,'%.2f'),'.']);
fprintf(fthresh_warn,'%s\n','Excessive dynamic range can be a sign of poor angular sampling.');
fclose(fthresh_warn);
