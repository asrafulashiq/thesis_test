function [HR_est]=Untitled(sig6_seg,Fs,cseg,mltplr,HR0,sig1_f,wname)



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

HRe_UNITY_F=findSignalPeaks_shrn(sig2_seg_UNITY,HR0,5,Fs);

for a=1:2
    HRe_UNITY_W(a)=sig2HR_wavelet_shrn(sig2_seg_UNITY(a,:),Fs,wname);
end

%%
HRe_EEMD_F=HRe_EEMD_F(:);HRe_mts1F=HRe_mts1F(:);HRe_TDEF=HRe_TDEF(:);HRe_EEMD_W=HRe_EEMD_W(:);HRe_UNITY_F=HRe_UNITY_F(:);HRe_UNITY_W=HRe_UNITY_W(:);
HR_acc=HR_acc(:);

HR_est=[HRe_EEMD_F;HRe_mts1F;HRe_TDEF;HRe_EEMD_W;HRe_UNITY_F;HRe_UNITY_W];
HR_est=zeros(12,1);
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
for a=1:length(HRe_UNITY_W)
    HR_est(10+a)=HRe_UNITY_W(a);
end

end
