clear all; clc;
%convertion on the signl to workable
rawdata=load('sig');
rawdata= struct2array(rawdata);
%building smaple time vector
delta= 1285/length(rawdata);
time = 0:delta:1285-delta;
%%
%filtering the signal
Fstop1 = 1;
Fpass1 = 5;
Fpass2 = 95;
Fstop2 = 100;
Astop1 = 65;
Apass  = 0.5;
Astop2 = 65;
Fs = 1e3;

fil = designfilt('bandpassfir', ...
  'StopbandFrequency1',Fstop1,'PassbandFrequency1', Fpass1, ...
  'PassbandFrequency2',Fpass2,'StopbandFrequency2', Fstop2, ...
  'StopbandAttenuation1',Astop1,'PassbandRipple', Apass, ...
  'StopbandAttenuation2',Astop2, ...
  'DesignMethod','equiripple','SampleRate',Fs);
fdata=filter(fil,rawdata);
%%
%using numeric differential method to detect the QRS
y0 = zeros(size(fdata));
y1 = zeros(size(fdata));
sum1 = zeros(size(fdata));
for i=2:length(fdata)
    if i< length(fdata),
        y0(i)=fdata(i-1)+fdata(i+1);
    end
    if i>2 && i< length(fdata)-2, 
        y1(i)= fdata(i+2)-2*fdata(i)+fdata(i-2);
    end
    sum1(i)= 1.3*y0(i)+1.1*y1(i);
end
k=800;
qrsstart=[];
rwaves=[];
f=1;
while f <length(fdata)-502
    if sum1(f)>k,
        counter=0;
        for i2=f:f+9
            if sum1(i2)<k,
                counter=counter+1;
            end
        end
        if counter<3,
            qrsstart(end+1)=f;
            f=f+300;
        end
    end
    f=f+1;
end
qrsstart=unique(qrsstart);
rmax=[];
for i3=2:length(qrsstart)
    [b,c]= max(fdata(qrsstart(i3-1):qrsstart(i3)));
    rwaves(end+1)=c+qrsstart(i3-1);
    rmax(end+1)=b;
end
% finding the hr
hr=zeros(size(time));
for j=1 : length ( rwaves)-1
    timehr= (rwaves(j+1)-rwaves(j))*delta;
    hr(rwaves(j):rwaves(j+1))=1/timehr;
end
figure();
subplot(4,1,1);
plot(time,rawdata);
xlim([50 59]);
xlabel('Time in sec'); ylabel('Milivolts');
title('Raw data between 50 and 59 sec');
subplot(4,1,2);
plot(time,fdata);
xlim([50 59]);
xlabel('Time in sec'); ylabel('Milivolts');
title('Filtered data between 50 and 59 sec');
subplot(4,1,3);
plot(time,fdata);
hold on;
scatter(rwaves*delta,rmax,6,'filled','r');
xlim([200 220]);
xlabel('Time in sec'); ylabel('Milivolts');
title(' R points');
subplot(4,1,4);
plot([0:length(hr)-1]*delta,hr);
xlabel('Time in sec');ylabel('Heartrate');
title('Heartrate per sec');
xlim([0 1280]);
phasez(fil);
fvtool(fil);
