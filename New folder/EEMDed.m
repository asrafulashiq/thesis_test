function [IMFavg]=EEMDed(sig4emd,Fs)
NE=8;
SNR=30;
imfs1={};
imfs2={};
HRe = -1;

imfToChose = [];
if Fs == 25
    imfToChose = 1;
elseif Fs == 125
    imfToChose = 2;
elseif Fs == 250
    imfToChose = 3;
elseif Fs == 500
    imfToChose = 4;
else
    error('Sampling frequency must be 25,125,250 or 500 Hz');
end


counter=1;
for i=1:NE
    rng(counter);
    counter=counter+1;
    
    iSig=1;
    sigWithNoise=awgn(sig4emd(iSig,:),SNR,'measured' );
    tmp_imfs=nwem_shrn( sigWithNoise );
    if length(tmp_imfs)>=2
        imfs1{i}=tmp_imfs{imfToChose};
    end
    rng(counter);
    counter=counter+1;
    
end
IMFavg={};
sumOfImfs=zeros(1,length(sig4emd(1,:)));
for i=1:length(imfs1)
    sumOfImfs=sumOfImfs+imfs1{i};
end
IMFavg=sumOfImfs;
end