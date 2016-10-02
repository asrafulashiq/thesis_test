function[HRe]=sig2HR_wavelet_shrn(PPGseg,Fs,wname)
Fc=centfrq(wname);
HR_down=40;HR_up=200;HR_step=.1;
HRw=HR_down:HR_step:HR_up;
Fw=HRw/60;
scales=Fs*Fc./Fw;
coefs=cwt(PPGseg,scales,wname);
Dmat(:,1:4)=[HRw',Fw',scales',sum(abs(coefs(:,:)'))'];
sDmat=sortrows(Dmat,-4);HRe=sDmat(1,1);
end

