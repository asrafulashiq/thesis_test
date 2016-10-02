%%                          PRE-PROCESSING
clear all;
clc;
close all;
format bank;
warning off;

p=mfilename('fullpath');
f=find(p=='/');
f(find(f==max(f)))=[];
f(find(f==max(f)))=[];
p(max(f)+1:end)=[];
datapath=[p 'Data_Bank/'];
varpath=[p 'Var_Bank/'];
addpath([p 'MATLAB_hacks']);


msg{1}='';
msg{2}='';
msg{3}='';
msg{4}='';
msgnow='';

%%
f1=figure('position',[15 60 1888 923],'name','Oscilloscope');%plot_protocol;
set(gcf,'color',[.9 .9 .85]*.98);

start_at=1;start_data=1;

flag=1;now=start_at;Data_ID=start_data;switch_data=1;carbil=' ';carbilflag=0;
while(1)
    window=now;
    Data_ID=Data_ID;
    
    %% MAIN CODE STARTS
    if switch_data==1
        switch_data=0;
        switch Data_ID
            case 1
                data='DATA_01_TYPE01';tag=1;window_no=148;start_steep=15;
            case 2
                data='DATA_02_TYPE02';tag=2;window_no=148;start_steep=16;
            case 3
                data='DATA_03_TYPE02';tag=3;window_no=140;start_steep=15;
            case 4
                data='DATA_04_TYPE02';tag=4;window_no=145;start_steep=16;
            case 5
                data='DATA_05_TYPE02';tag=5;window_no=146;start_steep=18;
            case 6
                data='DATA_06_TYPE02';tag=6;window_no=150;start_steep=15;
            case 7
                data='DATA_07_TYPE02';tag=7;window_no=143;start_steep=18;
            case 8
                data='DATA_08_TYPE02';tag=8;window_no=160;start_steep=12;
            case 9
                data='DATA_09_TYPE02';tag=9;window_no=149;start_steep=17;
            case 10
                data='DATA_10_TYPE02';tag=10;window_no=149;start_steep=13;
            case 11
                data='DATA_11_TYPE02';tag=11;window_no=142;start_steep=12;
            case 12
                data='DATA_12_TYPE02';tag=12;window_no=146;start_steep=19;
            case 13
                data='DATA_13_TYPE02';tag=13;window_no=14800;
            otherwise
                disp('Please try a valid Data ID..'); return;
        end
        total_window=window_no;
        
        %%                          LOAD DATA
        load([datapath data]);load([datapath data '_BPMtrace']);
        ECG=sig(1,:);PPG1=sig(2,:);PPG2=sig(3,:);accX=sig(4,:);accY=sig(5,:);accZ=sig(6,:);
        PPGm=(PPG1+PPG2)/2;sig6=sig;
        
        %%                         SET PARAMETERS
        Fs=125;
        wname='morl';
        will_save=0;
        
        %%                         CODE
        lRLS=40;ii=0;avg=0;
        %%
        str=[varpath 'PPGmXYZ_data_' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        l=dir(str);
        h=size(l);
        if h(1)
            load(str);
        else
            [~,PPGmX]=filter(adaptfilt.rls(lRLS),accX,PPGm);
            [~,PPGmXY]=filter(adaptfilt.rls(lRLS),accY,PPGmX);
            [~,PPGmXYZ]=filter(adaptfilt.rls(lRLS),accZ,PPGmXY);
            save(str,'PPGmXYZ');
        end
    end
    %% CODE
    mltplr=round(Fs/125);
    go=250*(window-1)+1;
    cseg=go:(go+1000*mltplr-1);
    PPGm_seg=PPGm(:,cseg);
    PPGmXYZ_seg=PPGmXYZ(:,cseg);
    accX_seg=accX(:,cseg);accY_seg=accY(:,cseg);accZ_seg=accZ(:,cseg);
    %%
    w=linspace(10,185,1000);
    ww=w/(Fs*60)*2*pi;
    str1=[varpath 'F_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str2=[varpath 'F_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str3=[varpath 'F_accX_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str4=[varpath 'F_accY_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str5=[varpath 'F_accZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    l=dir(str1);
    h=size(l);
    if h(1)
        load(str1);load(str2);load(str3);load(str4);load(str5);
    else
        F_PPGm_seg=abs(freqz(PPGm_seg,1,ww));
        F_PPGmXYZ_seg=abs(freqz(PPGmXYZ_seg,1,ww));
        F_accX_seg=abs(freqz(accX_seg,1,ww));
        F_accY_seg=abs(freqz(accY_seg,1,ww));
        F_accZ_seg=abs(freqz(accZ_seg,1,ww));
        save(str1,'F_PPGm_seg');save(str2,'F_PPGmXYZ_seg');
        save(str3,'F_accX_seg');save(str4,'F_accY_seg');
        save(str5,'F_accZ_seg');
    end
    
    str1=[varpath 'E_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str2=[varpath 'E_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str3=[varpath 'F_E_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str4=[varpath 'F_E_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    l=dir(str1);
    h=size(l);
    if h(1)
        load(str1);load(str2);load(str3);load(str4);
    else
        E_PPGm_seg=EEMDed(PPGm_seg,Fs);
        E_PPGmXYZ_seg=EEMDed(PPGmXYZ_seg,Fs);
        F_E_PPGm_seg=abs(freqz(E_PPGm_seg,1,ww));
        F_E_PPGmXYZ_seg=abs(freqz(E_PPGmXYZ_seg,1,ww));
        save(str1,'E_PPGm_seg');save(str2,'E_PPGmXYZ_seg');
        save(str3,'F_E_PPGm_seg');save(str4,'F_E_PPGmXYZ_seg');
    end
    
    str1=[varpath 'W_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    str2=[varpath 'W_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
    l=dir(str1);
    h=size(l);
    if h(1)
        load(str1);load(str2);
    else
        W_PPGm_seg=WAVELETed(PPGm_seg,Fs,wname);
        W_PPGmXYZ_seg=WAVELETed(PPGmXYZ_seg,Fs,wname);
        save(str1,'W_PPGm_seg');save(str2,'W_PPGmXYZ_seg');
    end
    
    
    %     [~,loc]=max(y);
    %     pks=w(loc);
    
    [p,q]=min(abs(w-BPM0(window)));
    xmin=10;xmax=185;
    %% PLOT
    subplot(3.3,3,2)
    plot(w,1.5*F_E_PPGm_seg/max(F_E_PPGm_seg));xlim([xmin xmax]);ylim([min(E_PPGm_seg/max(abs(E_PPGm_seg)))-.05 1.55]);hold on;plot(w,E_PPGm_seg/max(abs(E_PPGm_seg)),'m');plot(w(q),1.5*F_E_PPGm_seg(q)/max(F_E_PPGm_seg),'ko','markerfacecolor','g');hold off; title('Original PPG (\color{magenta}EEMD \color{black}and \color{blue}Fourier \color{black}domain)'); xlabel('Heart rate (corresponds to Fourier domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,5)
    plot(w,1.5*F_E_PPGmXYZ_seg/max(F_E_PPGmXYZ_seg));xlim([xmin xmax]);ylim([min(E_PPGmXYZ_seg/max(abs(E_PPGmXYZ_seg)))-.05 1.55]);hold on;plot(w,E_PPGmXYZ_seg/max(abs(E_PPGmXYZ_seg)),'m');plot(w(q),1.5*F_E_PPGmXYZ_seg(q)/max(F_E_PPGmXYZ_seg),'ko','markerfacecolor','g');hold off; title('RLS denoised PPG (\color{magenta}EEMD \color{black}and \color{blue}Fourier \color{black}domain)'); xlabel('Heart rate (corresponds to Fourier domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,1)
    plot(w,1.5*F_PPGm_seg/max(F_PPGm_seg));xlim([xmin xmax]);ylim([min(PPGm_seg/max(abs(PPGm_seg)))-.05 1.55]);hold on;plot(w,PPGm_seg/max(abs(PPGm_seg)),'c');plot(w(q),1.5*F_PPGm_seg(q)/max(F_PPGm_seg),'ko','markerfacecolor','g');hold off; title('\color{black}Original PPG (\color{cyan}Time \color{black}and \color{blue}Fourier \color{black}domain)'); xlabel('Heart rate (corresponds to Fourier domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,4)
    plot(w,1.5*F_PPGmXYZ_seg/max(F_PPGmXYZ_seg));xlim([xmin xmax]);ylim([min(PPGmXYZ_seg/max(abs(PPGmXYZ_seg)))-.05 1.55]);hold on;plot(w,PPGmXYZ_seg/max(abs(PPGmXYZ_seg)),'c');plot(w(q),1.5*F_PPGmXYZ_seg(q)/max(F_PPGmXYZ_seg),'ko','markerfacecolor','g');hold off; title('\color{black}RLS denoised PPG (\color{cyan}Time \color{black}and \color{blue}Fourier \color{black}domain)'); xlabel('Heart rate (corresponds to Fourier domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,7)
    plot(w,1.5*F_accX_seg/max(F_accX_seg));xlim([xmin xmax]);ylim([min([accX_seg/max(abs(accX_seg)) 1.5*F_accX_seg/max(F_accX_seg)])-.05 1.55]);hold on;plot(w,accX_seg/max(abs(accX_seg)),'g');plot(w(q),1.5*F_accX_seg(q)/max(F_accX_seg),'ko','markerfacecolor','g');hold off; title('Accelerometer data X-axis (\color{green}Time \color{black}and \color{blue}Fourier \color{black}domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,8)
    plot(w,1.5*F_accY_seg/max(F_accY_seg));xlim([xmin xmax]);ylim([min([accY_seg/max(abs(accY_seg)) 1.5*F_accY_seg/max(F_accY_seg)])-.05 1.55]);hold on;plot(w,accY_seg/max(abs(accY_seg)),'g');plot(w(q),1.5*F_accY_seg(q)/max(F_accY_seg),'ko','markerfacecolor','g');hold off; title('Accelerometer data Y-axis (\color{green}Time \color{black}and \color{blue}Fourier \color{black}domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,9)
    plot(w,1.5*F_accZ_seg/max(F_accZ_seg));xlim([xmin xmax]);ylim([min([accZ_seg/max(abs(accZ_seg)) 1.5*F_accZ_seg/max(F_accZ_seg)])-.05 1.55]);hold on;plot(w,accZ_seg/max(abs(accZ_seg)),'g');plot(w(q),1.5*F_accZ_seg(q)/max(F_accZ_seg),'ko','markerfacecolor','g');hold off; title('Accelerometer data Z-axis (\color{green}Time \color{black}and \color{blue}Fourier \color{black}domain)'); ylabel('Normalized magnitude');
    subplot(3.3,3,3)
    plot(W_PPGm_seg(:,1),W_PPGm_seg(:,2),'r');xlim([xmin xmax]); hold on; plot(w(q),W_PPGm_seg(q,2),'ko','markerfacecolor','g');hold off; title('Original PPG (\color{red}Wavelet \color{black}domain)'); xlabel('Heart rate'); ylabel('Normalized magnitude');
    subplot(3.3,3,6)
    plot(W_PPGmXYZ_seg(:,1),W_PPGmXYZ_seg(:,2),'r');xlim([xmin xmax]); hold on; plot(w(q),W_PPGmXYZ_seg(q,2),'ko','markerfacecolor','g'); hold off; title('RLS denoised PPG (\color{red}Wavelet \color{black}domain)'); xlabel('Heart rate'); ylabel('Normalized magnitude');
    %% MAIN CODE ENDS
    
    sh1=subplot(23,1,23);
    xax=[[1:100]';[1:total_window-100]'];yax=[3*ones(100,1);ones(total_window-100,1)];
    if now==1
        plot(xax(now),yax(now),'ks','markerfacecolor','r','markersize',11);text(xax(now)-.5,yax(now)-((now<=100)*2+2.75),[num2str(now) '-th window']);xlim([1 100]);ylim([1 3]);hold on
        plot(xax(now+1:end),yax(now+1:end),'ks','markersize',9);
    elseif now>95&now<100
        plot(xax(1:now-1),yax(1:now-1),'ks','markerfacecolor',[0.2 0.2 1],'markersize',9);xlim([1 100]);ylim([1 3]);hold on
        plot(xax(now),yax(now),'ks','markerfacecolor','r','markersize',11);text(xax(96)-.5,yax(now)-((now<=100)*2+2.75),[num2str(now) '-th window'])
        plot(xax(now+1:end),yax(now+1:end),'ks','markersize',9);
    elseif now==100
        plot(xax(1:now-1),yax(1:now-1),'ks','markerfacecolor',[0.2 0.2 1],'markersize',9);xlim([1 100]);ylim([1 3]);hold on
        plot(xax(now),yax(now),'ks','markerfacecolor','r','markersize',11);text(xax(96)-1,yax(now)-((now<=100)*2+2.75),[num2str(now) '-th window'])
        plot(xax(now+1:end),yax(now+1:end),'ks','markersize',9);
    else
        plot(xax(1:now-1),yax(1:now-1),'ks','markerfacecolor',[0.2 0.2 1],'markersize',9);xlim([1 100]);ylim([1 3]);hold on
        plot(xax(now),yax(now),'ks','markerfacecolor','r','markersize',11);text(xax(now)-.5,yax(now)-((now<=100)*2+2.75),[num2str(now) '-th window'])
        plot(xax(now+1:end),yax(now+1:end),'ks','markersize',9);
    end
    
    colr='k';hpos=102;vpos=4;
    text(hpos,vpos+.5,'_________________','color',colr);text(hpos,vpos-6.8,'_________________','color',colr);
    text(hpos-0.1,vpos-1.2,'|','color',colr);text(hpos-0.1,vpos-2.6,'|','color',colr);text(hpos-0.1,vpos-4,'|','color',colr);text(hpos-0.1,vpos-5.4,'|','color',colr);text(hpos-0.1,vpos-6.8,'|','color',colr);text(hpos-0.1,vpos-8.2,'|','color',colr);text(hpos-0.1,vpos-9.6,'|','color',colr);text(hpos-0.1,vpos-11,'|','color',colr);text(hpos-0.1,vpos-12.4,'|','color',colr);text(hpos-0.1,vpos-13.8,'|','color',colr);
    text(103.5,-1.6,'to toggle mode','color','k');
    ht2=text(103.5,-5.6,'..');ht4=text(103.5,-5.6,'..');ht6=text(103.5,-5.6,'..');ht8=text(103.5,-5.6,'..');ht10=text(103.5,-5.6,'..');ht12=text(103.5,-5.6,'..');ht14=text(103.5,-5.6,'..');
    set(ht2,'visible','off');set(ht4,'visible','off');set(ht6,'visible','off');set(ht8,'visible','off');set(ht10,'visible','off');set(ht12,'visible','off');set(ht14,'visible','off');
    ht1=text(103.5,-6,'Press X to exit.','color','r','fontweight','bold');
    ht3=text(103.5,1.6,'Keyboard mode','color','b','fontweight','bold');
    ht5=text(103.5,0,'Press up-arrow','color','k');
    
    colr='k';hpos=-15.5;
    text(hpos,vpos+.5,'________________________','color',colr);
    text(hpos+14.5,2.8,'|','color',colr);text(hpos+14.5,1.4,'|','color',colr);text(hpos+14.5,0,'|','color',colr);text(hpos+14.5,-1.4,'|','color',colr);text(hpos+14.5,-2.8,'|','color',colr);text(hpos+14.5,-4.2,'|','color',colr);text(hpos+14.5,-5.6,'|','color',colr);text(hpos+14.5,-7,'|','color',colr);text(hpos+14.5,-8.4,'|','color',colr);text(hpos+14.5,-9.8,'|','color',colr);
    text(hpos+1,0,'to navigate.','color','k');
    ht7=text(hpos+1,1.6,'Press left / right arrows','color','k');
    
    colr='k';hpos=105;vpos=19;
    text(hpos,vpos+.5,'_________________','color',colr);text(hpos,vpos-6.8,'_________________','color',colr);
    text(hpos-0.1,vpos-1.2,'|','color',colr);text(hpos-0.1,vpos-2.6,'|','color',colr);text(hpos-0.1,vpos-4,'|','color',colr);text(hpos-0.1,vpos-5.4,'|','color',colr);text(hpos-0.1,vpos-6.8,'|','color',colr);
    ht9=text(105.4,16.6,'Press');
    ht11=text(105.4,15,'1 - 9, A - C');
    ht13=text(105.4,13.4,'to switch data.');
    
    
    
    px=106.5;py=66;
    hdt1=text(px,py,'Data-01');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=62;
    hdt2=text(px,py,'Data-02');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=58;
    hdt3=text(px,py,'Data-03');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=54;
    hdt4=text(px,py,'Data-04');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=50;
    hdt5=text(px,py,'Data-05');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=46;
    hdt6=text(px,py,'Data-06');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=42;
    hdt7=text(px,py,'Data-07');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=38;
    hdt8=text(px,py,'Data-08');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=34;
    hdt9=text(px,py,'Data-09');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=30;
    hdt10=text(px,py,'Data-10');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=26;
    hdt11=text(px,py,'Data-11');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    px=106.5;py=22;
    hdt12=text(px,py,'Data-12');
    text(px-1,py-1,'|');text(px-1,py,'|');text(px-1,py+1,'|');
    text(px+4.5,py-1,'|');text(px+4.5,py,'|');text(px+4.5,py+1,'|');
    text(px-0.5,py-1,'_');text(px+0.5,py-1,'_');text(px+1.5,py-1,'_');text(px+2.5,py-1,'_');text(px+3.5,py-1,'_');
    text(px-0.5,py+2.5,'_');text(px+0.5,py+2.5,'_');text(px+1.5,py+2.5,'_');text(px+2.5,py+2.5,'_');text(px+3.5,py+2.5,'_');
    
    
    px=106.5;py=70-Data_ID*4;
    if Data_ID<10
        str=['Data-0' num2str(Data_ID)];
    else
        str=['Data-' num2str(Data_ID)];
    end
    switch Data_ID
        case 1
            set(hdt1,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 2
            set(hdt2,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 3
            set(hdt3,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 4
            set(hdt4,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 5
            set(hdt5,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 6
            set(hdt6,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 7
            set(hdt7,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 8
            set(hdt8,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 9
            set(hdt9,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 10
            set(hdt10,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 11
            set(hdt11,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        case 12
            set(hdt12,'visible','off');
            text(px-.25,py,str,'color','b','fontweight','bold','fontsize',11);
        otherwise
            
    end
    
    
    text(px-1,py-1,'|','color','r','fontweight','bold');text(px-1,py,'|','color','r','fontweight','bold');text(px-1,py+1,'|','color','r','fontweight','bold');
    text(px+4.5,py-1,'|','color','r','fontweight','bold');text(px+4.5,py,'|','color','r','fontweight','bold');text(px+4.5,py+1,'|','color','r','fontweight','bold');
    text(px-0.5,py-1,'_','color','r','fontweight','bold');text(px+0.5,py-1,'_','color','r','fontweight','bold');text(px+1.5,py-1,'_','color','r','fontweight','bold');text(px+2.5,py-1,'_','color','r','fontweight','bold');text(px+3.5,py-1,'_','color','r','fontweight','bold');
    text(px-0.5,py+2.5,'_','color','r','fontweight','bold');text(px+0.5,py+2.5,'_','color','r','fontweight','bold');text(px+1.5,py+2.5,'_','color','r','fontweight','bold');text(px+2.5,py+2.5,'_','color','r','fontweight','bold');text(px+3.5,py+2.5,'_','color','r','fontweight','bold');
    
    
    msg{1}=msg{2};msg{2}=msg{3};msg{3}=msg{4};msg{4}=msgnow;msgnow='';
    hpos=103.5;vpos=10;
    text(hpos,vpos,msg{1},'color',[.74 .74 .74]);
    text(hpos,vpos-1*1.4,msg{2},'color',[.48 .48 .48]);
    text(hpos,vpos-2*1.4,msg{3},'color',[.24 .24 .24]);
    text(hpos,vpos-3*1.4,msg{4},'color',[0 0 0]);
    
    
    hold off;axis off
    if carbilflag==1
        set(ht9,'visible','off');set(ht11,'visible','off');set(ht13,'visible','off');
        ht10=text(105.4,16.4,'Move to');
        ht12=text(105.4,15,'window:');
        carbil='_ _ _';ht14=text(105.4,13.6,carbil);
        for a=1:3
            car(a)=getkey(1);
            car(a)=car(a)-48;
            carbil(a*2-1)=num2str(car(a));
            ht14=text(105.4,13.6,carbil);
        end
        carbil=' ';
        now=car(1)*100+car(2)*10+car(3);
        if now<1
            now=1;
        end
        if now>total_window
            now=total_window;
        end
        %         flag=1;
        carbilflag=0;msgnow=[num2str(now) '-th window'];
        continue;
    end
    if flag
        X=getkey(1);
        if X==30
            flag=0;msgnow='Mouse activated..';
            continue;
        elseif X==88|X==120
            break;
        end
        
        if X==49
            Data_ID=1;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==50
            Data_ID=2;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==51
            Data_ID=3;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==52
            Data_ID=4;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==53
            Data_ID=5;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==54
            Data_ID=6;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==55
            Data_ID=7;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==56
            Data_ID=8;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==57
            Data_ID=9;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==65|X==97
            Data_ID=10;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==66|X==98
            Data_ID=11;now=1;switch_data=1;msgnow='Data changed..';continue;
        elseif X==67|X==99
            Data_ID=12;now=1;switch_data=1;msgnow='Data changed..';continue;
        end
        
        if X==28
            now=now-1;
            msgnow='Moving left..';
        elseif X==29
            now=now+1;
            msgnow='Moving right..';
        else
            msgnow='Wrong key..';
            continue;
        end
        if now<1
            now=1;
        end
        if now>total_window
            now=total_window;
        end
    else
        set(ht1,'visible','off');set(ht3,'visible','off');set(ht5,'visible','off');set(ht7,'visible','off');set(ht9,'visible','off');set(ht11,'visible','off');set(ht13,'visible','off');
        ht2=text(103,-6,'Click here to exit.','color','r','fontweight','bold');
        ht4=text(103.5,1.6,'Mouse mode','color','b','fontweight','bold');
        ht6=text(103.5,0,'Click right-button','color','k');
        ht8=text(-14.5,1.6,'Click on the windows','color','k');
        ht10=text(105.4,16.4,'Move to');
        ht12=text(105.4,15,'window:');
        ht14=text(105.4,13.6,carbil);
        carbil=' ';
        
        [x,y,butt]=ginput(1);
        if butt==3
            flag=1;msgnow='Keys activated..';continue;
        else
            msgnow='Window shifted..';
        end
        if x>104&y>11
            if x>104&y<19
                carbil='_ _ _';carbilflag=1;continue;
            end
        end
        
        xW=ceil(x-.5);
        if xW>100
            xW=100;
        end
        if xW<1
            xW=1;
        end
        xW=xW+100*(y<2);
        if xW>total_window
            break;
        end
        now=xW;
    end
    %%
    clc
    
end

close all
disp('Run ended..')