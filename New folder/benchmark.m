for window=1:window_no
    %%        PRE-PROCESSING
    lRLS=40;ii=0;avg=0;
    mltplr=round(Fs/125);sig1=PPGm;
    [~,PPGmX]=filter(adaptfilt.rls(lRLS),accX,sig1);
    [~,PPGmXY]=filter(adaptfilt.rls(lRLS),accY,PPGmX);
    [~,PPGmXYZ]=filter(adaptfilt.rls(lRLS),accZ,PPGmXY);
    sig1_f=myBandPass_shrn(PPGmXYZ,Fs);
    accXf=myBandPass_shrn(accX,Fs);
    accYf=myBandPass_shrn(accY,Fs);
    accZf=myBandPass_shrn(accZ,Fs);
    if window==1
        HR0=initialize_shrn(sig1_f(1:1000),sig6(4:6,1:1000),Fs);
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
    
    
    %%           MAIN WORK
    sig6_seg=sig6(:,cseg);
    
    %%           TRANSFORMS
    sig2_seg_UNITY=sig6_seg(2:3,:);                                   % UNITY transform
    sig2_seg_EEMD=EEMD(sig6_seg,Fs);                                  % EEMD transform
    sig1_f_seg=sig1_f(cseg);                                          % FILTER+UNITY transform
    sig2_seg_TDE=TDE(sig6_seg,mltplr);                                % TDE transform
    
    %%           NOISE FREQUENCY ESTIMATION
    threshold=0.5;
    HR_acc=[];
    for a=4:6
        accData=sig6_seg(a,:);
        pks_vector=maxFindFromThreshold_shrn(accData,threshold,Fs);
        if length(pks_vector)>3
            pks_vector=pks_vector(1:3);
        end
        HR_acc=[HR_acc,pks_vector];
    end
    
    %%           SIGNAL FREQUENCY ESTIMATION
    
    HRe_EEMD_F=zeros(1,2);
    for a=1:2
        sig4maxFind=sig2_seg_EEMD(a,:);
        pks=maxFind_shrn(sig4maxFind,Fs);
        HRe_EEMD_F(a)=pks;
    end
    
    HRe_mts1F=maxFindFromThreshold_shrn(sig1_f_seg,0.8,Fs);
    
    HRe_TDEF=zeros(1,2);
    for a=1:2
        sig4maxFind=sig2_seg_TDE(a,:);
        pks=maxFind_shrn(sig4maxFind,Fs);
        HRe_TDEF(a)=pks;
    end
    
    HRe_EEMD_W=zeros(1,2);
    for a=1:2
        sig4maxFind=sig2_seg_EEMD(a,:);
        pks=sig2HR_wavelet_shrn(sig4maxFind,Fs,wname); %/change/
        HRe_EEMD_W(a)=pks;
    end
    
    HR0
    HRe_UNITY_F=findSignalPeaks_shrn(sig2_seg_UNITY,HR0,5,Fs)
    
    %%         POST-PROCESSING
    for a=1:length(HRe_EEMD_F)
        [HRe_EEMD_F(a),ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe_EEMD_F(a),4,0);
    end
    for a=1:length(HRe_mts1F)
        [HRe_mts1F(a),ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe_mts1F(a),4,0);
    end
    for a=1:length(HRe_TDEF)
        [HRe_TDEF(a),ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe_TDEF(a),4,0);
    end
    for a=1:length(HRe_EEMD_W)
        [HRe_EEMD_W(a),ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe_EEMD_W(a),4,0);
    end
    for a=1:length(HRe_UNITY_F)
        [HRe_UNITY_F(a),ii]=call_nlms2_shrn(PPG1(cseg),PPG2(cseg),mltplr,HRe_UNITY_F(a),4,0);
    end
    
    HRe_EEMD_F=HRe_EEMD_F(:);HRe_mts1F=HRe_mts1F(:);HRe_TDEF=HRe_TDEF(:);HRe_EEMD_W=HRe_EEMD_W(:);HRe_UNITY_F=HRe_UNITY_F(:);
    HR4m1=ones(size(HRe_EEMD_F))*'a';HR4m2=ones(size(HRe_mts1F))*'b';HR4m3=ones(size(HRe_TDEF))*'c';HR4m4=ones(size(HRe_EEMD_W))*'d';HR4m5=ones(size(HRe_UNITY_F))*'e';
    HR_acc=HR_acc(:);HR4m=[HR4m1;HR4m2;HR4m3;HR4m4;HR4m5];
    
    HR_est=[HRe_EEMD_F;HRe_mts1F;HRe_TDEF;HRe_EEMD_W;HRe_UNITY_F];
    HR_est=zeros(10,1);
    for a=1:length(HRe_EEMD_F)
        HR_est(0+a)=HRe_EEMD_F(a);
    end
    for a=1:length(HRe_mts1F)
        HR_est(2+a)=HRe_mts1F(a);
    end
    for a=1:length(HRe_TDEF)
        HR_est(4+a)=HRe_TDEF(a);
    end
    for a=1:length(HRe_EEMD_W)
        HR_est(6+a)=HRe_EEMD_W(a);
    end
    for a=1:length(HRe_UNITY_F)
        HR_est(8+a)=HRe_UNITY_F(a);
    end
    
    
    methchart(:,window)=HR_est;
    
    HR_acc;
    HR_est;
    HR_true=BPM0(window);
    HR0;
    
    %
    [mv,ml]=min(abs(HR_est-HR_true));
    HRe(window)=HR_est(ml);
    %
    err(window)=abs(HRe(window)-HR_true);
    avg=mean(err);
    clc
    HR_est
%     disp(['Mean error = ' num2str(avg) ' (after ' num2str(window) '-th window)'])
    disp(['Window error = ' num2str(err(window)) ' (@ ' num2str(window) '-th window)'])
    %
    HR0=HRe(window);
end
BPM1=HRe;
%%                     SAVE
if will_save
    %     save([varpath 'Scrl03_ShrnHR_targ_est_' num2str(tag)],'BPM1')
    %     save([varpath 'Scrl03_Shrn_whichtype_est_' num2str(tag)],'HRt')
    save([varpath 'Scrl03_Shrn_methchart_' num2str(tag)],'methchart')
end
