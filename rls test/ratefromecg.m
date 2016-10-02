function r = ratefromecg(ecg)

    fSampling = 125;
    [~,pos] = findpeaks(ecg,'MINPEAKHEIGHT',0.1*max(ecg));
    
    d = mean(diff(pos));
    
    r = fSampling / d * 60;

end