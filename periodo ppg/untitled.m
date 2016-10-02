fSampling  = 125;
fileNo = 13;
[sig, bpm0 ] =  input_file(fileNo);

ecgSignal  = sig(1,:); % original ecg signal
ppgSignal1 = sig(2,:); % ppg signal 1
ppgSignal2 = sig(3,:); % ppg signal 2

% acceleration data of x,y,z
accDataX = sig(4,:);
accDataY = sig(5,:);
accDataZ = sig(6,:);

ppgSignalAverage = (ppgSignal1 + ppgSignal2) / 2;

w = linspace(30,200,1000);
ww = 2*pi*w/(fSampling*60);

iCounter = 1;

iStart = 1;
iStep  = 250  ;
iStop  = length(ppgSignal1) - 1000  ;
iSegment = iStart;


while iSegment <= iStop
    
    currentSegment = iSegment : ( iSegment + 1000  - 1 );
    
    f1 = abs(freqz(ecgSignal(currentSegment),1,ww));
    figure(1);
    plot(w,f1/max(f1),'r');
    
    f2 = abs(freqz(ppgSignal1(currentSegment),1,ww));
    hold on;
    plot(w,f2/max(f2),'-g');
    
    
    f3 = abs(freqz(ppgSignal2(currentSegment),1,ww));
    hold on;
    plot(w,f3/max(f3),'-b');
    
%     a1 = abs(freqz(accDataX(currentSegment),1,ww));
%     figure(2);
%     plot(w,a1/max(a1),'r');
%     
%     a2 = abs(freqz(accDataY(currentSegment),1,ww));
%     hold on;
%     plot(w,a2/max(a2),'g');
%     
%     a3 = abs(freqz(accDataZ(currentSegment),1,ww));
%     hold on;
%     plot(w,a3/max(a3),'b');

    figure(2);
    plot(accDataX(currentSegment),'r');
    hold on;plot(accDataY(currentSegment),'g');
    hold on;plot(accDataZ(currentSegment),'b');
    
    fprintf('%d: %.2f\n',iCounter,bpm0(iCounter));
    
    
    
    iCounter = iCounter + 1;
    
    iSegment = iSegment + iStep;
    
    clf(1);clf(2);
        
    
end

