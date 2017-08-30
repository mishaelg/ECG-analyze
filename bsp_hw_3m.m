
%convertion on the signl to workable
rawdata=load('sig.mat');
rawdata= struct2array(rawdata);

%building smaple time vector
delta= 662/length(rawdata);
time = 0:delta:662-delta;
%using numeric differential method to detect the QRS
y0 = zeros(size(rawdata));
y1 = zeros(size(rawdata));
sum1 = zeros(size(rawdata));
for i=2:length(rawdata)
    if i< length(rawdata),
        y0(i)=rawdata(i-1)+rawdata(i+1);
    end
    if i>2 & i< length(rawdata)-2, 
        y1(i)= rawdata(i+2)-2*rawdata(i)+rawdata(i-2);
    end
    sum1(i)= 1.3*y0(i)+1.1*y1(i);
end
k=2300;
qrsstart=[];
rwaves=[];
f=1;
while f <length(rawdata)-502
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
    [b,c]= max(rawdata(qrsstart(i3-1):qrsstart(i3)));
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
subplot(3,1,1);
plot(time,rawdata);
xlim([3 10]);
xlabel('Time in sec'); ylabel('Milivolts');
title('Raw data between 3 and 10 sec');
subplot(3,1,2);
plot(time,rawdata);
hold on;
scatter(rwaves*delta,rmax,6,'filled','r');
xlim([10 1000]);
xlabel('Time in sec'); ylabel('Milivolts');
title(' R points');
subplot(3,1,3);
plot([0:length(hr)-1]*delta,hr);
xlabel('Time in sec');ylabel('Heartrate');
title('Heartrate per sec');
xlim([0 660]);


