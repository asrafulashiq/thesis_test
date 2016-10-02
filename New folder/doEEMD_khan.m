function [HRe,peaks]=doEEMD_khan(sig4emd,HR0,del_cnt,Fs)
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
    
    iSig=2;
    sigWithNoise=awgn(sig4emd(iSig,:),SNR,'measured' );
    tmp_imfs=nwem_khan( sigWithNoise );
    if length(tmp_imfs) >= 2
        imfs1{i} = tmp_imfs{imfToChose};
    end
    rng(counter); 
    counter=counter+1;
    
    iSig=3;
    sigWithNoise=awgn(sig4emd(iSig,:),SNR,'measured' );
    tmp_imfs = nwem_khan( sigWithNoise );
    if length(tmp_imfs) >= 2
        imfs2{i} = tmp_imfs{imfToChose};
    end
end

IMFavg={};
sumOfImfs=zeros(1,length(sig4emd(2,:)));
for i=1:length(imfs1)
    sumOfImfs=sumOfImfs+imfs1{i};
end


IMFavg{1} = sumOfImfs;

sumOfImfs = zeros(1,length(sig4emd(3,:)));
for i = 1:length(imfs2)
    sumOfImfs = sumOfImfs + imfs2{i};
end


IMFavg{2} = sumOfImfs;



%%








S_imf=zeros(1,2);
for a=1:2
    sig4maxFind=IMFavg{a};
    pks=maxFind_khan(sig4maxFind,Fs);
    S_imf(a)=pks;
end

threshold=0.5;
S_acc=[];
for a=4:6
    accData=sig4emd(a,:);
    pks_vector=maxFindFromThreshold_khan(accData,threshold,Fs);
    if length(pks_vector)>3
        pks_vector=pks_vector(1:3);
    end
    S_acc=[S_acc,pks_vector];
end





S_imf_acc_3=[] ;
G_2=[];

for a=1:length(S_imf)
    if min(abs(S_imf(a)-S_acc))>3
        S_imf_acc_3=[S_imf_acc_3 S_imf(a)];
        if a==1
            if abs(S_imf(1)-S_imf(2))<2
                G_2=[G_2,mean(S_imf)];
            else
                G_2=[G_2,S_imf(a)];
            end
        elseif a==2
            G_2=[G_2,S_imf(a)];
        end
    end
end

peaks=S_imf_acc_3;

if isempty(G_2)
    return;
end

f_AC=[];
if max(G_2)-min(G_2)<= 2
    f_AC=mean(G_2);
else
    [~,loc]=min(abs(G_2-HR0));
    f_AC=G_2(loc);
end

delta_0=5;

delta_d=0.5;

delta_AC=delta_0+del_cnt*delta_d;

if abs(f_AC-HR0)<=delta_AC
    HRe=f_AC;
end

end


