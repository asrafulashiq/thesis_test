f2=figure('position',[970 190 950 600]);
f1=figure('position',[0 190 950 600]);
naX=nan*zeros(size(BPM0));
naY=nan*zeros(size(BPM0));
naZ=nan*zeros(size(BPM0));
for window=1:window_no
    mltplr=1;
    go=250*(window-1)+1;
    cseg=go:(go+1000*mltplr-1);
    
    aX=accX(cseg);
    aY=accY(cseg);
    aZ=accZ(cseg);
    
    naX(window)=norm(abs(aX));
    naY(window)=norm(abs(aY));
    naZ(window)=norm(abs(aZ));
    
    %%   PLOT
    set(0,'currentfigure',f1);
    subplot(211)
    plot([1:length(BPM0)],BPM0,'k');hold on
    plot(window,BPM0(window),'o','linewidth',1)
    title('Heart rate')
    hold off
    subplot 234
    plot(aX,'k');ylim([-4 4])
    title('accX')
    subplot 235
    plot(aY,'k');ylim([-4 4])
    title('accY')
    subplot 236
    plot(aZ,'k');ylim([-4 4])
    title('accZ')
    
    
    set(0,'currentfigure',f2);
    subplot 311
    plot([1:length(naX)],naX,'k.');
    subplot 312
    plot([1:length(naY)],naY,'k.');
    subplot 313
    plot([1:length(naZ)],naZ,'k.');
    xlabel(num2str(tag))
    
    pause(.1)
end

saveas(f2,[varpath 'prf_res\Scrl03_HRest_' num2str(tag) '.fig']);
