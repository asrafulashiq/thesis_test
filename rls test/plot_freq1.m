function plot_freq1(x,act_x)

len = length(x);

fSampling = 125;
w = linspace(50,200,1000);
ww = 2*pi*w/(fSampling*60);

f1 = periodogram(x,hamming(len),ww);

%f1 = pwelch(x,hamming(len),len/2,ww);


plot(w,f1);

xx = act_x*2*pi/(fSampling*60);

if nargin>1
    
    f = periodogram(x,hamming(len),[xx,xx+1]);
    %f = pwelch(x,hamming(len),len/2,[xx,xx+1]);
    
    hold on;
    plot(act_x,f(1),'or');
    
end


end