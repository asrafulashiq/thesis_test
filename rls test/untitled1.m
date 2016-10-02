fileNo = 1;

[sig, bpm0 ] =  input_file(fileNo);

sig  = sig(1,1:1000); % original ecg signal

fSampling = 125;
w = linspace(50,150,4096);
ww = 2 * pi * w / (fSampling * 60); 
fSig = abs(freqz(sig, 1, ww));

N = 2^15;
f = abs(fft(sig,N));
f = f( floor(50/(60*125)*2^15) :  floor(150/(60*125)*N));
