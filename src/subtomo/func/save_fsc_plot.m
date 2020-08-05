function save_fsc_plot(p,o,v,idx,corr_fsc,fsc,mean_rfsc)
%% Plot

% Plot corrected FSC
f = figure('visible','off');
hold on
n_shells = numel(fsc);
plot(1:n_shells,corr_fsc,'LineWidth',2,'Color','k')
plot(1:n_shells,fsc,'LineWidth',1,'Color','b');
plot(1:n_shells,mean_rfsc,'LineWidth',1,'Color','r');

% Apply Y-axis settings
grid on
axis ([0 n_shells -0.1 1.05]);
set(gca, 'yTick', [0 0.143 0.5 1.0]);
ylabel('Fourier Shell Correlation','FontSize',14);


% Apply X-axis settings
if isfield(o,'pixelsize')
    % Label with resolutions at approximate fractions of Nyquist
    res_label = ceil((o.pixelsize*20)./[0.25,0.5,0.75,1])./10;  % Rounds to nearest 0.1 Angstrom
    x_res = ((o.pixelsize*2)./res_label).*n_shells;
    xlabel('Resolution (Angstroms)','FontSize',14);
else
    % Label with fraction Nyquist
    res_label = [0.25,0.5,0.75,1];
    x_res = res_label.*n_shells;
    xlabel('Resolution (Fraction Nyquist)','FontSize',14);
end
set(gca, 'XTickLabel', res_label)
set(gca, 'XTick', x_res)


% Add legend
legend('Corrected FSC','Uncorrected FSC','Phase-randomized FSC')


% Set position
set(gca,'units','normalized','position',[0.15,0.15,0.75,0.75])

% Save FSC plots
fsc_name = [o.fscdir,'/fsc_',v.out_ref_names{3}];

saveas(f,[p(idx).rootdir,'/',fsc_name],'pdf')
