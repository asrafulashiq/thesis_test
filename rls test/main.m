%clear;
%close all;

total_file_no = 12;

fSampling = 125 ; % sampling frequency of the data
multiplier = round(fSampling/125);

bpm_estimeates = zeros(total_file_no,1);
avg_error = zeros(total_file_no,1);

isDebug = 0 ; % debug mode false by default:

% write the results in a new file
% create new file
fileToSaveResult = 'result.txt';
% fileID = fopen(fileToSaveResult,'w');
% fprintf(fileID,'####### \nRESULT : \n----------------\n');
% fclose(fileID);

% open file for append
fileID = fopen(fileToSaveResult,'a');

fprintf(fileID,'axyz combined:\n');

for fileNo =  10:total_file_no
    
    fprintf(fileID,'----------\nfile no : %d\n---------\n',fileNo);
    
    ii = 0;
    avg = 0;
    
    [sig, bpm0 ] =  input_file(fileNo);
    
    ecgSignal  = sig(1,:); % original ecg signal
    ppgSignal1 = sig(2,:); % ppg signal 1
    ppgSignal2 = sig(3,:); % ppg signal 2
    
    % acceleration data of x,y,z
    accDataX = sig(4,:);
    accDataY = sig(5,:);
    accDataZ = sig(6,:);
    
    accDataXYZ = sqrt( sig(4,:).^2 + sig(5,:).^2 + sig(6,:).^2 );
    
    sig_ = sig;
    
    ppgSignalAverage = (ppgSignal1 + ppgSignal2) / 2;
    
    %      accData = 1/3*sqrt(accDataX.^2+accDataY.^2+accDataZ.^2);
    %      lParameterOfRls = 40;
    %      [~,e] = filter(adaptfilt.rls(lParameterOfRls),accData,...
    %          ppgSignalAverage);
    %      rRaw = e;
    
    %         lParameterOfRls = 40;
    %         H = dsp.RLSFilter(lParameterOfRls);
    %         [~,ex] = step(H,accDataX,ppgSignalAverage);
    %         [~,exy] = step(H,accDataY,ex);
    %         [~,exyz] = step(H,accDataZ,exy);
    
    %rls filtering
%     lParameterOfRls = 40; % rls filter parameter
%     [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
%         ppgSignalAverage);
%     [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
%     [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
%     rRaw = exyz;  % exyz can be regarded as a denoised signal rRaw(n)
%     % which is assumed to have no correlation with the
%     % acceleration.
%     
%     
%     %% rls of ppg1 & 2
%     lParameterOfRls = 40; % rls filter parameter
%     [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
%         ppgSignal1);
%     [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
%     [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
%     rRaw1 = exyz;
%     
%     % ppg 2
%     lParameterOfRls = 40; % rls filter parameter
%     [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
%         ppgSignal2);
%     [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
%     [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
%     rRaw2 = exyz;
%     
%     rN1       = myBandPass(rRaw1,fSampling);
%     rN2       = myBandPass(rRaw2,fSampling);
%     
%     [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ,...
%         ppgSignal1);
%     
%     rNN1 = myBandPass(ex,fSampling);
%     
%     [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ,...
%         ppgSignal2);
%     
%     rNN2 = myBandPass(ex,fSampling);
%     
%     %%
%     
%     % filtering all data to frequency range for human HR
%     rN       = myBandPass(rRaw,fSampling);
%     accDataX = myBandPass(accDataX,fSampling);
%     accDataY = myBandPass(accDataY,fSampling);
%     accDataZ = myBandPass(accDataZ,fSampling);
%     
%     fPrev = initialize( rN(1:1000), sig(4:6,1:1000), fSampling ); % intial value of bpm
%     
%     
    % bandpassing all the data of signal
    filterObj = fdesign.bandpass( 70/(fSampling*60), 80/(fSampling*60),...
        400/(fSampling*60), 410/(fSampling*60), 80, 0.01, 80  );
    D = design(filterObj,'iir');
    for i=2:6
        sig(i,:)=filter(D,sig(i,:));
    end
%     
%     % now doing the emd portion
    
    iStart = 1;
    iStep  = 250 * multiplier ;
    iStop  = length(ecgSignal) - 1000 * multiplier ;
    
    delta_count = 0 ; % need in EEMD
    
    iCounter = 1;
    % For debug
    
    iSegment = iStart;
    
    while iSegment <= iStop
        
        fprintf('#######\n%d\n-------',iCounter);
        
        
        % for debug
        if iCounter>=54
            1;
        end
        fh=findall(0,'type','figure');
        for i=1:length(fh)
            clo(fh(i));
        end
        
        if isDebug==1
            % set isDebug
            % set iCounter
            % set fPrev
            iSegment = iStart + (iCounter-1) * iStep ;
            
        end
        
        
        
        currentSegment = iSegment : ( iSegment + 1000 * multiplier - 1 );
        
        %%  plot actual signal
        
        act_x = bpm0(iCounter);
        
        lParameterOfRls = 40;
        
        [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ(currentSegment),...
         ppgSignal1(currentSegment));
        rn1 = ex;
        
        
        [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ(currentSegment),...
         ppgSignal2(currentSegment));
        rn2 = ex;
        
        [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ(currentSegment),...
         ppgSignalAverage(currentSegment));
        rn3 = ex;
        
        
        
        figure(1);
        
        subplot(7,1,1);
        plot_freq1(ecgSignal(currentSegment),act_x);
        title('ecg signal')
        
        subplot(7,1,2);
        plot_freq1(ppgSignal1(currentSegment),act_x);
        title('ppg 1');
        
        subplot(7,1,3);
        plot_freq1(ppgSignal2(currentSegment),act_x);
        title('ppg 2');
        
        subplot(7,1,4);
        plot_freq1(ppgSignalAverage(currentSegment),act_x);
        title('ppg average');
        
        subplot(7,1,5);
        plot_freq1(rn1,act_x);
        title('ppg1 after rls average');
        
        subplot(7,1,6);
        plot_freq1(rn2,act_x);
        title('ppg2 after rls average');
        
        subplot(7,1,7);
        plot_freq1(rn3,act_x);
        title('ppg-average after rls average');
        
        %
        figure(2);
        
        subplot(4,2,1);
        plot_freq1(accDataX(currentSegment),act_x);
        title('psd of ax');
        
        subplot(4,2,3);
        plot_freq1(accDataY(currentSegment),act_x);
        title('psd of ay');
        
        subplot(4,2,5);
        plot_freq1(accDataZ(currentSegment),act_x);
        title('psd of az');
        
        subplot(4,2,2);
        plot(currentSegment,sig(4,currentSegment));
        title('ax');
        
        subplot(4,2,4);
        plot(currentSegment,sig(4,currentSegment));
        title('ay');
        
        subplot(4,2,6);
        plot(currentSegment,sig(4,currentSegment));
        title('az');
        
        
        subplot(4,2,7);
        plot_freq1(accDataXYZ(currentSegment),act_x);
        title('psd of axyz');
        
        subplot(4,2,8);
        plot(currentSegment,accDataXYZ(currentSegment));
        title('axyz');
        
        %%
        
%         [~,ex] = filter(adaptfilt.rls(lParameterOfRls),ecgSignal(currentSegment),...
%          ppgSignal1(currentSegment));
%         
%         figure(3);
%         plot_freq1(ex,act_x);
        
     
        %%
        
        
        %         fprintf('\n freq : %.2f\n',freqEstimates);
        %         fprintf('actual : %.2f , actual  : %.2f\n', bpm0(iCounter));
        %
        %         bpm_estimeates(fileNo,iCounter) = freqEstimates;
        %         err = freqEstimates - bpm0(iCounter);
        %
        %         fprintf('error : %.2f\n',err);
        %
        %         avg=(avg*(iCounter-1)+abs(err))/iCounter;
        %
        %         fprintf('\naverage : %.2f\n',avg);
        %         fprintf(fileID,' #%d : error : %.2f , average : %.2f\n   prev : %.2f , freq : %.2f, actual : %.2f\n'...
        %             ,iCounter,err,avg,fPrev,freqEstimates,bpm0(iCounter));
        %
        %         iCounter = iCounter + 1;
        %         fPrev = freqEstimates;
        
        iSegment = iSegment + iStep;
        %hold off;
    end
    
    %     avg_error(fileNo) = avg;
    %
    %     fprintf(fileID,'Average Error : %.2f \n',avg);
    %     fprintf(fileID,'--------------------');
    %     fprintf(fileID,'--------------------');
    
    
    
end

% fprintf(fileID,'Total average error : %.2f \n',mean(avg_error));
% fprintf(fileID,'--------------------');


fclose(fileID);
