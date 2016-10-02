%%                          PRE-PROCESSING
clear all;
clc;
close all;
format bank;
warning off;

p=mfilename('fullpath');
f=find(p=='\');
f(find(f==max(f)))=[];
f(find(f==max(f)))=[];
p(max(f)+1:end)=[];
datapath=[p 'Data_Bank\'];
varpath=[p 'Var_Bank\'];
addpath([p 'MATLAB_hacks']);


msg{1}='';
msg{2}='';
msg{3}='';
msg{4}='';
msgnow='';

%%
start_at=1;start_data=1;

flag=1;now=start_at;Data_ID=start_data;switch_data=1;carbil=' ';carbilflag=0;
for Data_ID=1:12
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
    total_window=window_no;
    for window=1:total_window
        
        %%                          LOAD DATA
        load([datapath data]);load([datapath data '_BPMtrace']);
        ECG=sig(1,:);PPG1=sig(2,:);PPG2=sig(3,:);accX=sig(4,:);accY=sig(5,:);accZ=sig(6,:);
        PPGm=(PPG1+PPG2)/2;sig6=sig;
        
        %%                         SET PARAMETERS
        Fs=125;
        wname='morl';
        will_save=0;
        
        %%                         CODE
        lRLS=40;ii=0;avg=0;
        %%
        str=[varpath 'PPGmXYZ_data_' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        l=dir(str);
        h=size(l);
        if h(1)
            load(str);
        else
            [~,PPGmX]=filter(adaptfilt.rls(lRLS),accX,PPGm);
            [~,PPGmXY]=filter(adaptfilt.rls(lRLS),accY,PPGmX);
            [~,PPGmXYZ]=filter(adaptfilt.rls(lRLS),accZ,PPGmXY);
            save(str,'PPGmXYZ');
        end
        %% CODE
        mltplr=round(Fs/125);
        go=250*(window-1)+1;
        cseg=go:(go+1000*mltplr-1);
        PPGm_seg=PPGm(:,cseg);
        PPGmXYZ_seg=PPGmXYZ(:,cseg);
        accX_seg=accX(:,cseg);accY_seg=accY(:,cseg);accZ_seg=accZ(:,cseg);
        %%
        w=linspace(10,185,1000);
        ww=w/(Fs*60)*2*pi;
        
        str1=[varpath 'F_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str2=[varpath 'F_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str3=[varpath 'F_accX_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str4=[varpath 'F_accY_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str5=[varpath 'F_accZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        l=dir(str1);
        h=size(l);
        if h(1)
            load(str1);load(str2);load(str3);load(str4);load(str5);
        else
            F_PPGm_seg=abs(freqz(PPGm_seg,1,ww));
            F_PPGmXYZ_seg=abs(freqz(PPGmXYZ_seg,1,ww));
            F_accX_seg=abs(freqz(accX_seg,1,ww));
            F_accY_seg=abs(freqz(accY_seg,1,ww));
            F_accZ_seg=abs(freqz(accZ_seg,1,ww));
            save(str1,'F_PPGm_seg');save(str2,'F_PPGmXYZ_seg');
            save(str3,'F_accX_seg');save(str4,'F_accY_seg');
            save(str5,'F_accZ_seg');
        end
        
        str1=[varpath 'E_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str2=[varpath 'E_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str3=[varpath 'F_E_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str4=[varpath 'F_E_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        l=dir(str1);
        h=size(l);
        if h(1)
            load(str1);load(str2);load(str3);load(str4);
        else
            E_PPGm_seg=EEMDed(PPGm_seg,Fs);
            E_PPGmXYZ_seg=EEMDed(PPGmXYZ_seg,Fs);
            F_E_PPGm_seg=abs(freqz(E_PPGm_seg,1,ww));
            F_E_PPGmXYZ_seg=abs(freqz(E_PPGmXYZ_seg,1,ww));
            save(str1,'E_PPGm_seg');save(str2,'E_PPGmXYZ_seg');
            save(str3,'F_E_PPGm_seg');save(str4,'F_E_PPGmXYZ_seg');
        end
        
        str1=[varpath 'W_PPGm_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        str2=[varpath 'W_PPGmXYZ_seg' num2str(Data_ID) '_window_' num2str(window)  '.mat'];
        l=dir(str1);
        h=size(l);
        if h(1)
            load(str1);load(str2);
        else
            W_PPGm_seg=WAVELETed(PPGm_seg,Fs,wname);
            W_PPGmXYZ_seg=WAVELETed(PPGmXYZ_seg,Fs,wname);
            save(str1,'W_PPGm_seg');save(str2,'W_PPGmXYZ_seg');
        end
        dd=['data_' num2str(Data_ID) '_window_' num2str(window)];
        disp(dd);
    end
    clc
end
