function [r,p,m] = mycorr(a,b)
    
    ea = sum(a.^2);
    eb = sum(b.^2);
    
    [r,p] = xcorr(a,b);
    r = r/(sqrt(ea*eb));
    
    m = max(r);
    
end