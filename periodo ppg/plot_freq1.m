function plot_freq1(x,act_x)

len = length(x);

fSampling = 125;
w = linspace(50,200,1000);
ww = 2*pi*w/(fSampling*60);

f1 = periodogram(x,[],ww);

%f1 = pwelch(x,(len),len/2,ww);


plot(w,f1);

xx = act_x*2*pi/(fSampling*60);

if ~isempty(act_x)
    
    f = periodogram(x,[],[xx,xx+1]);
    %f = pwelch(x,hamming(len),len/2,[xx,xx+1]);
    
    hold on;
    plot(act_x,f(1),'or');
    
end


end