%%
addpath = ('/Users/zhangjinming/Desktop/MatlabCode')
addpath = ('/Users/zhangjinming/Desktop/MatlabCode/npy-matlab')

%Load raw data and define its plotting metrics
% *Dose not need to run this section if you don not want to draw a raw data illustration* 
D = load_open_ephys_binary(['/Users/zhangjinming/Desktop/实验结果/博士课题/多通道电生理' ...
    '/JZL195/Baseline/1#-32Ch_2022-08-29_12-52-22_Baseline/Record Node 113/experiment1/recording1/structure.oebin'],'continuous',1);
for r = 17:32 %Load raw data per channel (16-channel)
    eval(['Y' num2str(r-16) '=bandpass(D.Data(r,:),[300 3000],30000)']) %[300 3000]bandpass range, 30000 sampling frequency
end 

%% 
%load prefered electrodes of all K templates(Assign detected cells to its prefered Channels)
CellElectrodesFile = ['/Users/zhangjinming/Desktop/实验结果/博士课题/多通道电生理' ...
    '/JZL195/Baseline/1#-32Ch_2022-08-29_12-52-22_Baseline/Record Node 113/experiment1/recording1/continuous/Rhythm_FPGA-100.0/continuous/continuous.clusters-merged.hdf5'];
CellTimestamp      = ['/Users/zhangjinming/Desktop/实验结果/博士课题/多通道电生理' ...
    '/JZL195/Baseline/1#-32Ch_2022-08-29_12-52-22_Baseline/Record Node 113/experiment1/recording1/continuous/Rhythm_FPGA-100.0/continuous/continuous.result-merged.hdf5'];
CellElectrodes     = double(h5read(CellElectrodesFile, '/electrodes')).';% Number of rows is the number of templates(cells) No. % Value in each cell is the Channel No.
for i=1:size(CellElectrodes);   %Load timestamps of spike on each detected Cell.
    eval(['CST_' num2str(i) '= double(h5read(CellTimestamp, ''/spiketimes/temp_' num2str(i-1) '''));']); % CST==CellSpikeTime
    %eval(['CTy' num2str(i)  '=ones(size(CST_' num2str(i) ',1),1)*2100;']);        
    eval(['ISI_' num2str(i)  '=diff((CST_' num2str(i) '))/30']); %Caculate ISI Unit: ms   %Caculate inter-spike intervals of each cell.
end

%Extracting spike waveforms (Delete 'SPKwave' from workspace before you turn to the next cell)
load RawDataperChannel/RawData.mat %use line 7 first if you don't have a RawData.mat file.
Y1_f = bandpass(Y1, [300 3000], 30000);
for j=1:100%size(CST_8,2);
    SPKwave(j,:)=Y1_f(1,CST_1(j)-30000*0.0015:CST_1(j)+30000*0.0015); % e.g. 30000samples/s*0.01=300samples/10ms
    %SPK=resample(SPKwave,1000,30000)
    hold on 
    plot(SPKwave(j,:),'Color',[.5 .5 .5]);   
end
hold on
plot(mean(SPKwave,1),'Color','r')
%如何将波形Y轴起点对齐？

%%
%convert template.npy to a 2D .mat file. NOTE: you should first convert the Spyking-circus results into a phy suppored .npy file using through Spyking-cirus command in terminal;
TempFile = readNPY(['/Users/zhangjinming/Desktop/实验结果/博士课题/多通道电生理' ...
    '/JZL195/Baseline/2#-32Ch_2022-08-29_13-10-06_Baseline/Record Node 113/experiment1/recording1/continuous/Rhythm_FPGA-100.0/continuous/continuous-merged.GUI/templates.npy'])
for i = 1:size(TempFile,1)
    Template(i,:,1) = TempFile(i,:,1)
end
mesh(Template)
