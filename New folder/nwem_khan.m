function imf=nwem_khan(x)
% Empiricial Mode Decomposition (Hilbert-Huang Transform)
% imf = emd(x)
% Func : findpeaks

x   = transpose(x(:));
imf = [];
while ~ismonotonic(x)
    x1 = x;
    sd = Inf;
    tot_itr=0;
    max_itr=1000;
    while ((sd > 0.1) || ~isimf(x1)) && tot_itr < max_itr
        tot_itr=tot_itr+1;
        s1 = getspline(x1);
        s2 = -getspline(-x1);
        x2 = x1-(s1+s2)/2;
        
        sd = sum((x1-x2).^2)/sum(x1.^2);
        x1 = x2;
    end
    
    imf{end+1} = x1;
    x          = x-x1;
end
imf{end+1} = x;

% FUNCTIONS

function u = ismonotonic(x)

u1 = length(fpeaks_khan(x))*length(fpeaks_khan(-x));
if u1 > 0, u = 0;
else     u = 1; end

function u = isimf(x)

N  = length(x);
u1 = sum(x(1:N-1).*x(2:N) < 0);
u2 = length(fpeaks_khan(x))+length(fpeaks_khan(-x));
if abs(u1-u2) > 1, u = 0;
else             u = 1; end

function s = getspline(x)

N = length(x);
p = fpeaks_khan(x);
s = spline([0 p N+1],[0 x(p) 0],1:N);