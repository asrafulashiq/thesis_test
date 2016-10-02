%clear;
%close all;

total_file_no = 12;

fSampling = 125 ; % sampling frequency of the data
multiplier = round(fSampling/125);

isDebug = 0 ; % debug mode false by default:

% write the results in a new file
% create new file
fileToSaveResult = 'ecg_axyz.txt';
% fileID = fopen(fileToSaveResult,'w');
% fprintf(fileID,'####### \nRESULT : \n----------------\n');
% fclose(fileID);

% open file for append
fileID = fopen(fileToSaveResult,'w');

fprintf(fileID,'bpm     pa\n');
fprintf(fileID,'---    -----\n');

X = [];
Y = [];

for fileNo = 1:total_file_no
   
    fprintf(fileID,'file No : %d\n----------\n',fileNo);
    
    
    [sig, bpm0 ] =  input_file(fileNo);
    
 
    iStart = 1;
    iStep  = 250 * multiplier ;
    iStop  = length(sig(1,:)) - 1000 * multiplier ;
    
    delta_count = 0 ; % need in EEMD
    
    iCounter = 1;
    % For debug
    
    iSegment = iStart;
    
    while iSegment <= iStop
        
        
        currentSegment = iSegment : ( iSegment + 1000 * multiplier - 1 );
        
        pa = sum(sig(4,currentSegment).^2+sig(5,currentSegment).^2+sig(6,currentSegment).^2);
        
        fprintf(fileID,'%.2f     %.2f\n',bpm0(iCounter),pa);
        X = [X, bpm0(iCounter)];
        Y = [Y, pa];
        
        iSegment = iSegment + iStep;
        iCounter = iCounter + 1;
        
    end
    
    
end

scatter(X,Y);

fclose(fileID);
