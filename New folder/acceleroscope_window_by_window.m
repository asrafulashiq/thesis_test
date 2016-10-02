mltplr=1;
go=250*(window-1)+1;
cseg=go:(go+1000*mltplr-1);


aX=accX(cseg);
aY=accY(cseg);
aZ=accZ(cseg);


%%   PLOT
f1=figure('position',[900 90 1000 630]);
subplot(211)
plot([1:length(BPM0)],BPM0,'k');hold on
plot(window,BPM0(window),'o','linewidth',1)
hold off;title('Heart rate')

subplot 234
plot(aX,'k');ylim([-4 4])
title('accX')
subplot 235
plot(aY,'k');ylim([-4 4])
title('accY')
subplot 236
plot(aY,'k');ylim([-4 4])
title('accZ')
xlabel(num2str(tag))