function plot_freq(x,act_x)

fSampling = 125;
w = linspace(50,200,1000);
ww = 2*pi*w/(fSampling*60);

f1 = abs(freqz(x,1,ww));
plot(w,f1);

xx = act_x*2*pi/(fSampling*60);

if ~isempty(act_x)
    
    f = abs(freqz(x,1,[xx,xx+1]));
    hold on;
    plot(act_x,f(1),'or');
    
end


end