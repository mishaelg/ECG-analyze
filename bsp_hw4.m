clear all; close all; clc;
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
%%now the changes for stage 3 of the hw
%downsampled signal
dss=downsample(rawdata,250);

ni=[];
for i=251 :250: length(rawdata)-251
    checker = find(rwaves>i-250& rwaves<i+250);
    
    if isempty(checker),
        d= find(rwaves>i+251);
        if isempty(d)==false,
        d= d(1);
        if d< length(rwaves)-1,
         l=rwaves(d+1)- rwaves(d);
         ni(end+1)= 2/250/l;
        end
        end
    elseif checker>1,
        mid= find(rwaves>i-250& rwaves<i+250);
        top= find(rwaves>i+250);
        if isempty(top)==false,
        top= top(1);
        if top(1)<length(rwaves-1)
          down=find(rwaves <i);
          down= down(end);
          a1=rwaves(mid) - i+250;
          a2=rwaves(mid)-rwaves(mid-1);
          a3=i+250-rwaves(mid);
          a4=rwaves(mid+1)-rwaves(mid);
          ni(end+1)= (a1/a2) + a3/a4;
        end
        end
    end
end
ri= ni*250/2/60;
timevec = 0.25:0.25:length(ri)/4;
figure(1);
plot(timevec,ri);title('HR as function of time'); xlabel('Time(Sec)'); ylabel('Heartrate per Sec');
figure(2);
pwelch(ri,[],[],[],4);
       