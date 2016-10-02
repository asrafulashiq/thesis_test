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

for fileNo =  2:total_file_no
    
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
    
    ecgSignal_  = sig(1,:); % original ecg signal
    ppgSignal1_ = sig(2,:); % ppg signal 1
    ppgSignal2_ = sig(3,:); % ppg signal 2
    
    % acceleration data of x,y,z
    accDataX_ = sig(4,:);
    accDataY_ = sig(5,:);
    accDataZ_ = sig(6,:);
    
    accDataXYZ = sqrt( sig(4,:).^2 + sig(5,:).^2 + sig(6,:).^2 );
    
    sig_ = sig;
    
    ppgSignalAverage = (ppgSignal1 + ppgSignal2) / 2;
    ppgSignalAverage_ = ppgSignalAverage;
    
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
    lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
        ppgSignalAverage);
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
    rRaw = exyz;  % exyz can be regarded as a denoised signal rRaw(n)
    % which is assumed to have no correlation with the
    % acceleration.
    %% for test
    %rRaw = ppgSignalAverage;
    
    %%
    
%     
    
    %% rls of ppg1 & 2
     lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
        ppgSignal1);
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
    rRaw1 = exyz;
    
    % ppg 2
     lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX,...
        ppgSignal2);
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY,ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ,exy);
    rRaw2 = exyz;
    
    rN1       = myBandPass(rRaw1,fSampling);
    rN2       = myBandPass(rRaw2,fSampling);
    
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ,...
        ppgSignal1);
    
    rNN1 = myBandPass(ex,fSampling);
    
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataXYZ,...
        ppgSignal2);
    
    rNN2 = myBandPass(ex,fSampling);
    
    %%
    
    % filtering all data to frequency range for human HR
    rN       = myBandPass(rRaw,fSampling);
    accDataX = myBandPass(accDataX,fSampling);
    accDataY = myBandPass(accDataY,fSampling);
    accDataZ = myBandPass(accDataZ,fSampling);
    
    fPrev = initialize( rN(1:1000), sig(4:6,1:1000), fSampling ); % intial value of bpm
    
    
    % bandpassing all the data of signal
    filterObj = fdesign.bandpass( 70/(fSampling*60), 80/(fSampling*60),...
        400/(fSampling*60), 410/(fSampling*60), 80, 0.01, 80  );
    D = design(filterObj,'iir');
    for i=2:6
        sig(i,:)=filter(D,sig(i,:));
    end
    
    % now doing the emd portion
    
    iStart = 1;
    iStep  = 250 * multiplier ;
    iStop  = length(rN) - 1000 * multiplier ;
    
    delta_count = 0 ; % need in EEMD
    
    iCounter = 1;
    % For debug
    
    iSegment = iStart;
    
    while iSegment <= iStop
        
        fprintf('#######\n%d\n-------',iCounter);
        
        % for debug
        if iCounter>=1
            1;
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
        
        fh=findall(0,'type','figure');
        for i=1:length(fh)
            clo(fh(i));
        end
        
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
        plot_freq1(rN(currentSegment),act_x);
        title('ppg after rls');
        
        subplot(7,1,6);
        plot_freq1(rN1(currentSegment),act_x);
        title('ppg1 after rls');
        
        subplot(7,1,7);
        plot_freq1(rN2(currentSegment),act_x);
        title('ppg2 after rls');
        
        
        
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
        
        axyz = sqrt(accDataX(currentSegment).^2 +...
                accDataY(currentSegment).^2+...
                accDataZ(currentSegment).^2);
        subplot(4,2,7);
        plot_freq1(axyz,act_x);
        title('psd of axyz');
        
        subplot(4,2,8);
        plot(currentSegment,accDataXYZ(currentSegment));
        title('axyz');
        
        
        %%
        
        
    %rls filtering
    lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX_(currentSegment),...
        ppgSignalAverage_(currentSegment));
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY_(currentSegment),ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ_(currentSegment),exy);
    rNN = exyz;  % exyz can be regarded as a denoised signal rRaw(n)
%     
    
    %% rls of ppg 1 & 2
     lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX_(currentSegment),...
        ppgSignal1_(currentSegment));
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY_(currentSegment),ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ_(currentSegment),exy);
    rRaw1 = exyz;
    
    % ppg 2
     lParameterOfRls = 40; % rls filter parameter
    [~,ex] = filter(adaptfilt.rls(lParameterOfRls),accDataX_(currentSegment),...
        ppgSignal2_(currentSegment));
    [~,exy] = filter(adaptfilt.rls(lParameterOfRls),accDataY_(currentSegment),ex);
    [~,exyz] = filter(adaptfilt.rls(lParameterOfRls),accDataZ_(currentSegment),exy);
    rRaw2 = exyz;
    
    rNN1       = myBandPass(rRaw1,fSampling);
    rNN2       = myBandPass(rRaw2,fSampling);
        
        
        %%
        figure(3);
        subplot(3,1,1);
        plot_freq1(rNN,act_x);
        title('ppg average rls');
        
        subplot(3,1,2);
        plot_freq1(rNN1,act_x);
        title('ppg 1');
        
        subplot(3,1,3);
        plot_freq1(rNN2,act_x);
        title('ppg 2');
        
        %%
        
        [freqEstimates,peaks] = doEEMD(sig(:,currentSegment),fPrev,delta_count,...
            fSampling,act_x);
        
        %%
%         figure(4);
%         subplot(2,1,1);
%         plot_freq1(rNN1(currentSegment),act_x);
%         title('ppg1 after xyz rls');
%         
%         subplot(2,1,2);
%         plot_freq1(rNN2(currentSegment),act_x);
%         title('ppg2 after xyz rls');
        %%
        
        fprintf('emd estimate : %f\n',freqEstimates);
        
        % we construct Simf \3 Sa, 0.5, and from this set, we
        % take the peak location nearest to fprev
        [minimum,loc] = min(abs(peaks - fPrev));
        
        freq_td = frequency_estimate( sig(2,currentSegment),...
            sig(3,currentSegment),sig(4,currentSegment),...
            sig(5,currentSegment),sig(6,currentSegment),...
            fPrev,multiplier);
        
        fprintf('freq td : %.2f\n',freq_td);
        
        
        if freqEstimates ~= -1
            % tracking from AC
            delta_count = 0;
            fprintf('tracking from AC : ');
            fprintf('%.2f',freqEstimates);
            
        elseif minimum <= 7 % If its distance from fprev is within 7 BPM
            % tracking from emd 2
            freqEstimates = peaks(loc);
            if delta_count>0
                delta_count = delta_count - 0.5;
            end
            fprintf('tracking from emd : %.2f\n',freqEstimates);
            
            %         elseif freq_td ~= -1 && abs(freq_td - fPrev ) < 12
            %             % from td
            %             fprintf('tracking from td : ');
            %             freqEstimates = freq_td;
            
        else % track from rls
            
            fprintf('//');
            
            delta_count = delta_count + 1;
            
            y_cropped = rN(currentSegment);
            
            % we put its dominant peaks (80% of the maximum) in
            % Srls
            S_rls = maxFindFromThreshold(y_cropped,0.6,fSampling); %%%%
            
            % We also construct Sa, 0.6 by taking the dominant peaks
            %(60% of the maximum, a moderate threshold for tracking
            % purpose) from a? (n)
            
            S_a = [];
            %             for iAcc = 4:6
            %
            %                 dominantPeaks = maxFindFromThreshold(sig(iAcc,currentSegment),...
            %                     0.6,fSampling);  %%%% thresh-hold was 0.6 in paper
            %                 if length(dominantPeaks)>2
            %                     dominantPeaks = dominantPeaks(1:2);
            %                 end
            %                 S_a = [S_a , dominantPeaks];
            %
            %             end
            
            % x
            dominantPeaks = maxFindFromThreshold(accDataXYZ(currentSegment),...
                0.8,fSampling);  %%%% thresh-hold was 0.6 in paper
            S_a = dominantPeaks;
%             if length(dominantPeaks)>2
%                 dominantPeaks = dominantPeaks(1:2);
%             end
%             S_a = [S_a , dominantPeaks];
%             % y
%             dominantPeaks = maxFindFromThreshold(accDataY(currentSegment),...
%                 0.6,fSampling);  %%%% thresh-hold was 0.6 in paper
%             if length(dominantPeaks)>2
%                 dominantPeaks = dominantPeaks(1:2);
%             end
%             S_a = [S_a , dominantPeaks];
%             % z
%             dominantPeaks = maxFindFromThreshold(accDataZ(currentSegment),...
%                 0.6,fSampling);  %%%% thresh-hold was 0.6 in paper
%             if length(dominantPeaks)>2
%                 dominantPeaks = dominantPeaks(1:2);
%             end
%             S_a = [S_a , dominantPeaks];
            
            
            % set Srls\3 Sa,0.6
            f_rls_set = [];
            
            for iRls = S_rls
                
                if min( abs( S_a - iRls ) ) > 3
                    f_rls_set = [f_rls_set , iRls];
                end
                
            end
            
            f_rls_set = f_rls_set( f_rls_set>40 & f_rls_set<200 );
            
            if length(f_rls_set)==1 && abs(f_rls_set-fPrev)<26.5 %%%%%%%%%%%
                delta_count = max([0;delta_count-1]);
                freqEstimates = f_rls_set(1);
                fprintf('tracking from rls : ');
                fprintf('%.2f \n',freqEstimates);
            elseif freq_td ~= -1 && abs(freq_td - fPrev ) < 12
                % from td
                fprintf('tracking from td : %.2f\n',freq_td);
                freqEstimates = freq_td;
                
            else
                
                fprintf('else : ');
                
                %%%% according to paper
                %                 % strongest peak in Srls is looked for such that it lies
                %                 % close to fprev within a range 7 - 12 BPM
                %
                %                 f_ = maxFind(y_cropped,fSampling);
                %                 if abs(f_ - fPrev) <= 9
                %                     freqEstimates = f_;
                %                 end
                
                if min(abs(S_rls-fPrev))<9
                    [~,pos] = min(abs(S_rls-fPrev));
                    freqEstimates = S_rls(pos);
                end
                
                if freqEstimates == -1
                    
                    % If the above steps fail to provide with the crude estimate
                    % f , then we consider all the peak locations attainable
                    % from the periodograms of yi (n) and array them together
                    % in a set Sorg
                    S_a0  = findSignalPeaks([sig(4,currentSegment);sig(5,currentSegment);sig(6,currentSegment)]...
                        ,fPrev,10,fSampling);
                    S_org = findSignalPeaks([sig(2,currentSegment);sig(3,currentSegment)]...
                        ,fPrev ,5,fSampling);
                    
                    
                    if abs(S_org - S_a0)>3
                        freqEstimates = S_org;
                    else
                        freqEstimates = fPrev;
                    end
                    
                    fprintf('%.2f',freqEstimates);
                    
                end
                
                
            end
        end
        
        [freqEstimates, ii]=call_nlms2(ppgSignal1(currentSegment),ppgSignal2(currentSegment),...
            multiplier,freqEstimates,4,ii);
        
        
        fprintf('\n freq : %.2f\n',freqEstimates);
        fprintf('actual : %.2f , actual  : %.2f\n', bpm0(iCounter));
        
        bpm_estimeates(fileNo,iCounter) = freqEstimates;
        err = freqEstimates - bpm0(iCounter);
        
        fprintf('error : %.2f\n',err);
        
        avg=(avg*(iCounter-1)+abs(err))/iCounter;
        
        fprintf('\naverage : %.2f\n',avg);
        fprintf(fileID,' #%d : error : %.2f , average : %.2f\n   prev : %.2f , freq : %.2f, actual : %.2f\n'...
            ,iCounter,err,avg,fPrev,freqEstimates,bpm0(iCounter));
        
        iCounter = iCounter + 1;
        fPrev = freqEstimates;
        
        iSegment = iSegment + iStep;
        %hold off;
    end
    
    avg_error(fileNo) = avg;
    
    fprintf(fileID,'Average Error : %.2f \n',avg);
    fprintf(fileID,'--------------------');
    fprintf(fileID,'--------------------');
    
    
    
end

fprintf(fileID,'Total average error : %.2f \n',mean(avg_error));
fprintf(fileID,'--------------------');


fclose(fileID);
