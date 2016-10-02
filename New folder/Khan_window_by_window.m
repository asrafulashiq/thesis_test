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

if window==1
    HR0=initialize_shrn(sig1_f(1:1000),sig6(4:6,1:1000),Fs);
else
    load([varpath 'Scrl03_KhanHRest_' num2str(tag)])
    HR0=BPM1(window-1); clear BPM1;
end

filterObj=fdesign.bandpass(70/(Fs*60),80/(Fs*60),...
    400/(Fs*60),410/(Fs*60),80,0.01,80);
D=design(filterObj,'iir');
for i=2:6
    sig6(i,:)=filter(D,sig6(i,:));
end

del_cnt=0;


ctaggg=0;
hrbpm1=[];hrbpm2=[];hrbpm3=[];
whrbpm1=[];whrbpm2=[];whrbpm3=[];


go=250*(window-1)+1;
cseg=go:(go+1000*mltplr-1);





sig6_seg=sig6(:,cseg);
[HRe,pks]=doEEMD_khan(sig6_seg,HR0,del_cnt,Fs);

[mnmm,loc]=min(abs(pks-HR0));

if HRe~=-1
    disp('1a')
    ctaggg=1;
    
    del_cnt=0;
    fprintf('tracking from AC: ');
elseif mnmm<=7
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
                disp('Setting HRe=HR0')
            end
        end
    end
end
[HRe,ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe,4,ii);
err=abs(HRe-BPM0(window));
BPM1=HRe;
fprintf(['\nError in BPM: %.2f at ' num2str(window) '-th window.\n'],err);