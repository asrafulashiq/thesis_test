function [y1,y2]=dis4mmean(b)
y1=abs(mean(b(1:end-1))-b(end));
y2=std(b(1:end-1));
end

