f1=figure('position',[90 90 655 415]);movegui(f1,'west');

lRLS=40;ii=0;avg=0;
pre_flag=0;pre_flag2=0;pre_flag3=0;
%%
mltplr=round(Fs/125);
sig1=PPGm;
%%
[~,PPGmX]=filter(adaptfilt.rls(lRLS),accX,sig1);
[~,PPGmXY]=filter(adaptfilt.rls(lRLS),accY,PPGmX);
[~,PPGmXYZ]=filter(adaptfilt.rls(lRLS),accZ,PPGmXY);

sig1_f=myBandPass_khan(PPGmXYZ,Fs);
accXf=myBandPass_khan(accX,Fs);
accYf=myBandPass_khan(accY,Fs);
accZf=myBandPass_khan(accZ,Fs);

HR0=initialize_khan(sig1_f(1:1000),sig6(4:6,1:1000),Fs)
%
filterObj=fdesign.bandpass(70/(Fs*60),80/(Fs*60),...
    400/(Fs*60),410/(Fs*60),80,0.01,80);
D=design(filterObj,'iir');
for i=2:6
    sig6f(i,:)=filter(D,sig6(i,:));
end




%
go=1;
pace=250*mltplr;
stop=length(sig1_f)-1000*mltplr;

del_cnt=0;
window=1;


ctaggg=0;
hrbpm1=[];hrbpm2=[];hrbpm3=[];
whrbpm1=[];whrbpm2=[];whrbpm3=[];
annpHR=[];annpW=[];
while go<=stop
    %     if window==91
    %         sdfjkslkdfjlsdkf
    %     end
    %     for i=2:6
    %         sig6(i,:)=filter(D,sig6(i,:));
    %     end
    %     H=modefreq(BPM0,ECG,Fs,PPG1,PPG2,PPGm,accX,accY,accZ,sig6,tag,varpath,will_save,window,window_no,wname)
    cseg=go:(go+1000*mltplr-1);
    
    sig6_seg=sig6f(:,cseg);
    [HRe,pks]=doEEMD_shrn(sig6_seg,HR0,del_cnt,Fs,wname);
    
    [mnmm,loc]=min(abs(pks-HR0));
    
    if HRe~=-1&mnmm<=6.55
        disp('1a')
        ctaggg=1;
        
        del_cnt=0;
        fprintf('tracking from AC: ');
    elseif mnmm<=3.4
        disp('1b')
        ctaggg=2;
        
        HRe=pks(loc);
        if del_cnt>0
            del_cnt=del_cnt-0.5;
        end
        fprintf('tracking from emd : ');
    else
        disp('1c')
        ctaggg=3;
        
        del_cnt=del_cnt+1;
        
        sig1_f_seg=sig1_f(cseg);
        
        S_rls=maxFindFromThreshold_khan(sig1_f_seg,0.8,Fs);
        
        S_a=[];
        dominantPeaks=maxFindFromThreshold_khan(accXf(cseg),0.6,Fs);
        if length(dominantPeaks)>2
            dominantPeaks=dominantPeaks(1:2);
        end
        S_a=[S_a,dominantPeaks];
        
        dominantPeaks=maxFindFromThreshold_khan(accYf(cseg),0.6,Fs);
        if length(dominantPeaks)>2
            dominantPeaks=dominantPeaks(1:2);
        end
        S_a=[S_a,dominantPeaks];
        
        dominantPeaks=maxFindFromThreshold_khan(accZf(cseg),0.6,Fs);
        if length(dominantPeaks)>2
            dominantPeaks=dominantPeaks(1:2);
        end
        S_a=[S_a,dominantPeaks];
        
        f_rls_set=[];
        
        for iRls=S_rls
            if min(abs(S_a-iRls))>3
                f_rls_set=[f_rls_set,iRls];
            end
        end
        f_rls_set=f_rls_set(f_rls_set>40&f_rls_set<200);
        
        
        
        
        
        s4fes2=sig6f(2,cseg);s4fes3=sig6f(3,cseg);a4fesx=sig6f(4,cseg);a4fesy=sig6f(5,cseg);a4fesz=sig6f(6,cseg);
        HRtd=frequency_estimate_khan(s4fes2,s4fes3,a4fesx,a4fesy,a4fesz,HR0,mltplr);
        if length(f_rls_set)==1 && abs(f_rls_set-HR0)<26.5
            del_cnt=max([0;del_cnt-1]);
            
            HRe=f_rls_set(1);
            
        elseif HRtd~=-1&&abs(HRtd-HR0)<12
            fprintf('tracking from td : ');
            HRe=HRtd;
        else
            if min(abs(S_rls-HR0))<9
                [~,pos]=min(abs(S_rls-HR0));
                HRe=S_rls(pos);
            end
            if HRe==-1
                S_a0=findSignalPeaks_khan([sig6f(4,cseg);sig6f(5,cseg);sig6f(6,cseg)],HR0,10,Fs);
                S_org=findSignalPeaks_khan([sig6f(2,cseg);sig6f(3,cseg)],HR0,5,Fs);
                if abs(S_org-S_a0)>3
                    HRe=S_org;
                else
                    HRe=HR0;
                end
            end
        end
        
    end
    
    if pre_flag==1
        if abs(HRe-HR0)>15.96
            HRe=HR0;
        end
    end
    pre_flag=0;
    if window>9
        jj=BPM1(window-1-(9-1):window-1);
        kk=jj>HR0;
        if kk==[1 1 1 1 0 0 0 0 0]
            pre_flag=1;
            if abs(HRe-HR0)>15.96
                HRe=HR0;
            end
        end
    end
    
    
    [HRe,ii]=call_nlms2_khan(PPG1(cseg),PPG2(cseg),mltplr,HRe,4,ii);
    
    
    
    %     %
    %     if H==-1
    %     else
    %         if abs(HR0-H)>10
    %         else
    %             if abs(H-HRe)>7
    %                 HRe=H;
    %             else
    %             end
    %         end
    %     end
    %     %
    %
    
    BPM1(window)=HRe;
    
    % 1
    back_sample=26;
    if window>back_sample
        
        predicted_value=next_predict(medfilt1(BPM1(back_sample-2:window-1),7));
        %         predicted_value=next_predict(BPM1(window-back_sample:window-1));
        
        pder(window)=abs(BPM1(window)-predicted_value);
        if pder(window)>12
            %             BPM1(window)=predicted_value;
            %             BPM1(window)=HR0;
        end
    end
    
    % 2
    if BPM1(window)>180
        BPM1(window)=HR0;
    end
    
    % 1..
    if window<=back_sample
    else
        thres=10;
        if pder(window)>thres&pder(window)<50
            
            if abs(BPM1(window)-HR0)>5
                if window<100 % crude crude crude
                    BPM1(window)=HR0;% % % % % %
                end
            end
        end
    end
    
    % 3
    if pre_flag2==0
    else
        BPM1(window)=HR0;% % % % % %
        pre_flag2=pre_flag2-1;
    end
    back_ano=16;
    if window>back_ano
        [ann1,ann2]=anomality(BPM1(window-back_ano:window));
        if ann1>9.6&ann2<0.9
            pre_flag2=5;
            BPM1(window)=HR0;% % % % % %
        end
    end
    
    % 4
    if window>130
        if pre_flag3==0
    else
        BPM1(window)=HR0;% % % % % %
        pre_flag3=pre_flag3-1;
    end
        if std(BPM1(window-11:window-1))<0.36
            pre_flag3=5;
            BPM1(window)=HR0;% % % % % %
            annpHR=[annpHR BPM1(window)];
            annpW=[annpW window];
        end
    end
    
    
    
    
    err(window)=abs(BPM1(window)-BPM0(window));
    avg=(avg*(window-1)+err(window))/window;
    
    pause(.001)
    set(0,'currentfigure',f1);
    plot([1:length(BPM0)],BPM0,'k');hold on;grid on;
    plot(1:window-1,BPM1(1:window-1),'b.');
    plot(window,BPM1(window),'go','markeredgecolor','k','markerfacecolor','g');
    plot(annpW,annpHR,'r.')
    hold off
    
    
    strstr1=sprintf('%.2f',err(window));strstr1=['window error: ' strstr1];
    strstr2=[];
    if window>back_sample
        strstr2=sprintf('%.2f',pder(window));strstr2=['predict error: ' strstr2];
    end
    legend(strstr2,strstr1,'location','southeast');
    set(gca,'fontsize',12);
    frdfke=sprintf('%.2f',mean(err));
    xlabel(['mean error: ' frdfke],'fontsize',12)
    ylabel(['Window: ' num2str(window)],'fontsize',12)
    title(['Data ' num2str(tag)]);legend boxoff
    
    %     clc
    fprintf('\nAverage error in BPM : %.2f\n',avg);
    fprintf('\nWindow error in BPM : %.2f\n',err(window));
    
    
    
    str=['We are sitting on ' num2str(window) '-th window, ' num2str(length(BPM0)-window) ' ta tao baki.'];
    disp(str)
    HR0=BPM1(window);
    window=window+1;
    go=go+pace;
    
    %     ii
end
disp('Shesh bangladesh!!')


%%                     SAVE
if will_save
    % default version
    %     save([varpath 'Scrl03_ShrnHRest_' num2str(tag)],'BPM1')
    
    % performance save version
    save([varpath 'prf_res\Scrl03_HRest_' num2str(tag)],'BPM1')
    saveas(f1,[varpath 'prf_res\Scrl03_HRest_' num2str(tag) '.fig']);
end