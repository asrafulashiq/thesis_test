function pks=maxFind_shrn(sig4maxFind,Fs)
w=linspace(0,200,1000);
ww=w/(Fs*60)*2*pi; % radian per sampling
y=abs(freqz(sig4maxFind,1,ww));
[~,loc]=max(y);
pks=w(loc);

end