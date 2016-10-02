lRLS=40;ii=0;avg=0;

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
        sig6(i,:)=filter(D,sig6(i,:));
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

while go<=stop
%     for i=2:6
%         sig6(i,:)=filter(D,sig6(i,:));
%     end
    cseg=go:(go+1000*mltplr-1);
    
    sig6_seg=sig6(:,cseg);
    [HRe,pks]=doEEMD_shrn(sig6_seg,HR0,del_cnt,Fs,wname);
    
    [mnmm,loc]=min(abs(pks-HR0));
    
    if HRe~=-1
        disp('1a')
        ctaggg=1;
        
        del_cnt=0;
        fprintf('tracking from AC: ');
    elseif mnmm<=4%7
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
        
        
        
        
        
        s4fes2=sig6(2,cseg);s4fes3=sig6(3,cseg);a4fesx=sig6(4,cseg);a4fesy=sig6(5,cseg);a4fesz=sig6(6,cseg);
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
                S_a0=findSignalPeaks_khan([sig6(4,cseg);sig6(5,cseg);sig6(6,cseg)],HR0,10,Fs);
                S_org=findSignalPeaks_khan([sig6(2,cseg);sig6(3,cseg)],HR0,5,Fs);
                if abs(S_org-S_a0)>3
                    HRe=S_org;
                else
                    HRe=HR0;
                end
            end
        end
        
        
        
    end
    [HRe,ii]=call_nlms2_khan(PPG1(cseg),PPG2(cseg),mltplr,HRe,4,ii);
    err(window)=abs(HRe-BPM0(window));
    BPM1(window)=HRe;
    avg=(avg*(window-1)+err(window))/window;
    clc
    fprintf('\nAverage error in BPM : %.2f\n',avg);
    fprintf('\nWindow error in BPM : %.2f\n',err(window));
    
    
    % %
    switch ctaggg
        case 1
            hrbpm1=[hrbpm1 HRe];
            whrbpm1=[whrbpm1 window];
        case 2
            hrbpm2=[hrbpm2 HRe];
            whrbpm2=[whrbpm2 window];
        case 3
            hrbpm3=[hrbpm3 HRe];
            whrbpm3=[whrbpm3 window];
        otherwise
            disp('I am done with you >:(')
    end
    % %
    
    
    str=['We are sitting on ' num2str(window) '-th window, ' num2str(length(BPM0)-window) ' ta tao baki.'];
    disp(str)
    window=window+1;
    HR0=HRe;
    go=go+pace;
    
    ii
end
disp('Shesh bangladesh!!')

%%                     SAVE
if will_save
    save([varpath 'Scrl03_KhanHRest_' num2str(tag)],'BPM1')
end

%%                     PLOT
f1=figure('position',[90 90 655 415]);movegui(f1,'west');
plot([1:length(BPM0)],BPM0,'k');hold on;grid on;
plot(whrbpm1,hrbpm1,'r.');plot(whrbpm2,hrbpm2,'g.');plot(whrbpm3,hrbpm3,'b.');
legend('Ground truth','location','southeast');
set(gca,'fontsize',12);
xlabel('Window frame','fontsize',12)
ylabel('Bits per minute','fontsize',12)
title('BPM vs WF');legend boxoff