function[Dmat]=WAVELETed(PPGseg,Fs,wname)
Fc=centfrq(wname);
HR_down=10;HR_up=185;
HRw=linspace(HR_down,HR_up,1000);
Fw=HRw/60;
scales=Fs*Fc./Fw;
coefs=cwt(PPGseg,scales,wname);
Dmat(:,1:2)=[HRw',sum(abs(coefs(:,:)'))'];
end

