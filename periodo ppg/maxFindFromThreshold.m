function maxFreqs = maxFindFromThreshold (sig,threshold,fSampling)

   w = linspace(0,300,4096);
   ww = 2*pi*w / (fSampling*60);
    
   Psig = abs(periodogram( sig,hamming(length(sig)),ww )).^2;
   figure;
   findpeaks(Psig,'minpeakheight',threshold * max(Psig),...
    'minpeakdistance',3,'SortStr','descend');
   
   [ ~ , maxLocs] =  findpeaks(Psig,'minpeakheight',threshold * max(Psig),...
    'minpeakdistance',3,'SortStr','descend');

    maxFreqs = w(maxLocs);

end