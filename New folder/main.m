%%                          PRE-PROCESSING
clear all;
clc;
close all;
format bank;

p=mfilename('fullpath');
f=find(p=='\');
f(find(f==max(f)))=[];
f(find(f==max(f)))=[];
p(max(f)+1:end)=[];
datapath=[p 'Data_Bank\'];
varpath=[p 'Var_Bank\'];
addpath([p 'MATLAB_hacks']);

%%                          SELECT DATA
Data_ID=10;

%%
switch Data_ID
    case 1
        data='DATA_01_TYPE01';tag=1;window_no=148;start_steep=15;
    case 2
        data='DATA_02_TYPE02';tag=2;window_no=148;start_steep=16;
    case 3
        data='DATA_03_TYPE02';tag=3;window_no=140;start_steep=15;
    case 4
        data='DATA_04_TYPE02';tag=4;window_no=145;start_steep=16;
    case 5
        data='DATA_05_TYPE02';tag=5;window_no=146;start_steep=18;
    case 6
        data='DATA_06_TYPE02';tag=6;window_no=150;start_steep=15;
    case 7
        data='DATA_07_TYPE02';tag=7;window_no=143;start_steep=18;
    case 8
        data='DATA_08_TYPE02';tag=8;window_no=160;start_steep=12;
    case 9
        data='DATA_09_TYPE02';tag=9;window_no=149;start_steep=17;
    case 10
        data='DATA_10_TYPE02';tag=10;window_no=149;start_steep=13;
    case 11
        data='DATA_11_TYPE02';tag=11;window_no=142;start_steep=12;
    case 12
        data='DATA_12_TYPE02';tag=12;window_no=146;start_steep=19;
    case 13
        data='DATA_13_TYPE02';tag=13;window_no=14800;
    otherwise
        disp('Please try a valid Data ID..'); return;
end

%%                          LOAD DATA
clearvars -except datapath varpath data tag window_no start_steep
load([datapath data]);load([datapath data '_BPMtrace']);clear datapath data;
ECG=sig(1,:);PPG1=sig(2,:);PPG2=sig(3,:);accX=sig(4,:);accY=sig(5,:);accZ=sig(6,:);
PPGm=(PPG1+PPG2)/2;sig6=sig;clear sig;

%%                         SET PARAMETERS
Fs=125;
wname='morl';
will_save=0;

%%                           RUN CODES
% Khan_et_al
% Himel_et_al
% Shrn_et_al

% sketch02_full
% sketch03_full
% sketch04_full
% sketch05_full
% sketch06_full
% sketch07_full
% sketch08_full
% sketch09_full
sketch10_full


%% Debugging
% window=16;

% Khan_window_by_window
% sketch01
% sketch02
% sketch03
% sketch04
% sketch05
% Untitled

%% Experiments
% window=18;
% acceleroscope_window_by_window

% acceleroscope
% H=modefreq(BPM0,ECG,Fs,PPG1,PPG2,PPGm,accX,accY,accZ,sig6,tag,varpath,will_save,window,window_no,wname)