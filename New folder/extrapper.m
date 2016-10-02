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

%%                          DATA
Data_ID=1;
switch Data_ID
    case 1
        data='DATA_01_TYPE01';tag=1;window_no=148;
    case 2
        data='DATA_02_TYPE02';tag=2;window_no=148;
    case 3
        data='DATA_03_TYPE02';tag=3;window_no=140;
    case 4
        data='DATA_04_TYPE02';tag=4;window_no=145;
    case 5
        data='DATA_05_TYPE02';tag=5;window_no=146;
    case 6
        data='DATA_06_TYPE02';tag=6;window_no=150;
    case 7
        data='DATA_07_TYPE02';tag=7;window_no=143;
    case 8
        data='DATA_08_TYPE02';tag=8;window_no=160;
    case 9
        data='DATA_09_TYPE02';tag=9;window_no=149;
    case 10
        data='DATA_10_TYPE02';tag=10;window_no=149;
    case 11
        data='DATA_11_TYPE02';tag=11;window_no=142;
    case 12
        data='DATA_12_TYPE02';tag=12;window_no=146;
    case 13
        data='DATA_13_TYPE02';tag=13;window_no=14800;
    otherwise
        disp('Please try a valid Data ID..'); return;
end
load([datapath data '_BPMtrace']);
clearvars -except BPM0





%%
now=1;
girth=60;
xBPM0=interp1([1:girth]',BPM0(now:now+girth-1),[1:girth+1]',[],'extrap');













