%%                          PRE-PROCESSING
clear all;
clc;
close all;
format long;

p=mfilename('fullpath');
f=find(p=='\');
f(find(f==max(f)))=[];
f(find(f==max(f)))=[];
p(max(f)+1:end)=[];
datapath=[p 'Data_Bank\'];
varpath=[p 'Var_Bank\'];
addpath([p 'MATLAB_hacks']);

%%                          LOAD DATA
for Data_ID=1:12
    clearvars -except addpath varpath datapath Data_ID
    close all
    %%
    switch Data_ID
        case 1
            data='DATA_01_TYPE01';tag=1;
        case 2
            data='DATA_02_TYPE02';tag=2;
        case 3
            data='DATA_03_TYPE02';tag=3;
        case 4
            data='DATA_04_TYPE02';tag=4;
        case 5
            data='DATA_05_TYPE02';tag=5;
        case 6
            data='DATA_06_TYPE02';tag=6;
        case 7
            data='DATA_07_TYPE02';tag=7;
        case 8
            data='DATA_08_TYPE02';tag=8;
        case 9
            data='DATA_09_TYPE02';tag=9;
        case 10
            data='DATA_10_TYPE02';tag=10;
        case 11
            data='DATA_11_TYPE02';tag=11;
        case 12
            data='DATA_12_TYPE02';tag=12;
        case 13
            data='DATA_13_TYPE02';tag=13;
        otherwise
            disp('Data ID not valid');
    end
    clearvars -except datapath varpath data tag
    load([datapath data]);load([datapath data '_BPMtrace']);
    ECG=sig(1,:);PPG1=sig(2,:);PPG2=sig(3,:);accX=sig(4,:);accY=sig(5,:);accZ=sig(6,:);
    PPGm=(PPG1+PPG2)/2;
    
    %%                          MID-PROCESSING
    
    %%                         SET PARAMETERS
    Fs=125;
    
    %%                           RUN CODES
    Khan_et_al
    % Himel_et_al
%     Shrn_et_al
    
    %%
%     save(['khan_' num2str(tag) '_err'],'err')
%     saveas(f1,[['khan_HR' num2str(tag) '.fig']])
end