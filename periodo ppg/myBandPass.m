function y = myBandPass(x,fSampling)
% myBandPass returns filtered data of x
    % y = myBandPass(x), passed through an infinite impulse 
    % response bandpass filter with lower and upper passband 
    % cut off at 40 and 200 BPM, respectively 
    % (typical fre- quency range for human HR), and 
    % lower and upper stopband cut off at 35 and 205 BPM, 
    % respectively, and passband ripple 0.01, 
    % stopband attenuation 80 dB 

filterObj=fdesign.bandpass(30/(fSampling*60), 40/(fSampling*60),...
                           400/(fSampling*60), 410/(fSampling*60),...
                            80, 1, 80);
designedFilter = design(filterObj, 'iir');

y = filter(designedFilter, x);

end