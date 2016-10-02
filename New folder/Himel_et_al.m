Tseg=8;Tovlp=6;
ppg1=sig6(2,:);ppg2=sig6(3,:);
ppg=(ppg1+ppg2)/2;

%% 
wname='morl';

%% 
window=0;BPM=[];
for t_check=8:2:8+2*floor((length(sig6)-Tseg*Fs)/((Tseg-Tovlp)*Fs))
    window=window+1;   
    
    cseg=(t_check-Tseg)*Fs+1:t_check*Fs;
    PPGseg=ppg(cseg);
    HR0=BPM0(window);
    HRe=sig2HR_wavelet_himel(PPGseg,Fs,wname);
    
    BPM(1,window)=HR0;
    BPM(2,window)=HRe;
end

%% PLOT
f1=figure('position',[90 90 655 415]);movegui(f1,'west');
plot([1:length(BPM)],BPM(1,:),'k');hold on;grid on;
plot([1:length(BPM)],BPM(2,:),'--b');
legend('Ground truth','Estimated','location','southeast');
set(gca,'fontsize',12);
xlabel('Window frame','fontsize',12)
ylabel('Bits per minute','fontsize',12)
title('BPM vs WF');legend boxoff