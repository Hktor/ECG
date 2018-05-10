%% find_PRT.m
%
% Author:   Hector Alvarez
% Date:     10.05.2018
%
% This function finds the P-R-T points in the ECG signal.
%
% Inputs:
%           ECG data                               - dt
%           Sampling Frequency                     - fs
%           Time                                   - tm

% Output: 
%           Pwave location                         - plcs
%           QRS-complex location                   - rlcs
%           Twave location                         - tlcs

%% Load ECG Raw Data File
function [plcs,rlcs,tlcs] = find_PQT(dt,fs,tm)
fprintf('LowBandPass Filtering...\n');

sz = size(dt,1);

% Average data in 100 milliseconds - filtering

fi = 5;
p = 1/(fi*2);
t = 0:1/fs:p;
t = t(1:end-1);
h = sin(2*pi*fi*t);
ftsz = size(h,2);
dly = round(ftsz/4);
av_dt = conv(dt,h);

avg_dt = zeros(sz,1);
avg_dt((1:end-dly)) = av_dt(dly+1:sz);

% Extract P-wave, QRS-complex, T-wave - filtering

fi = 20;
p = 1/fi;
t = 0:1/fs:p;
t = t(1:end-1);
h = sin(2*pi*fi*t);
ftsz = size(h,2);
dly = round(ftsz/4);
sn_dt = conv(avg_dt,h);

sin_dt = zeros(sz,1);
sin_dt((1:end-dly)) = sn_dt(dly+1:sz);

sin_dt = sin_dt/max(sin_dt);
sin_dt(sin_dt<0) = 0;

% Find P-wave and T-wave

fi = 1;
p = 1/(fi*2);
t = 0:1/fs:p;
t = t(1:end-1);
h = sin(2*pi*fi*t);
ftsz = size(h,2);
dly = round(ftsz/4);
hr_dt = conv(sin_dt,h);

car_dt = zeros(sz,1);
car_dt((1:end-dly)) = hr_dt(dly+1:sz);

car_dt = car_dt/max(car_dt);

[~,tlcs,~] = findpeaks(car_dt,tm);
[~,plcs,~] = findpeaks(-car_dt,tm);

% Find P-wave, QRS-complex and T-wave

fi = 3;
p = 1/(fi*2);
t = 0:1/fs:p;
t = t(1:end-1);
h = sin(2*pi*fi*t);
ftsz = size(h,2);
dly = round(ftsz/4);
hr_dt = conv(dt,h);

car_dt = zeros(sz,1);
car_dt((1:end-dly)) = hr_dt(dly+1:sz);

car_dt = car_dt/max(car_dt);

[~,lcs,~] = findpeaks(car_dt,tm);

% Eliminate incomplete detections

tlcs = tlcs(tlcs>plcs(1));

lcs = lcs(lcs>plcs(1));
lcs = lcs(lcs<tlcs(end));

plcs = plcs(plcs<tlcs(end));

% Number of full activations detected

nOfact = size(plcs,1);

% Remove duplicated peaks

for i=1:nOfact
    lcs(lcs>tlcs(i)-0.05 & lcs<tlcs(i)+0.05) = [];
    lcs(lcs>plcs(i)-0.05 & lcs<plcs(i)+0.05) = [];
end

% Build triplets

rlcs = zeros(nOfact,1);
twv  = zeros(nOfact,1);
pwv  = zeros(nOfact,1);
qrs  = zeros(nOfact,1);

for i=1:nOfact
    rlcs(i) = lcs(lcs>plcs(i) & lcs<tlcs(i));
    
    twv(i) = dt(tm==tlcs(i));
    pwv(i) = dt(tm==plcs(i));
    qrs(i) = dt(tm==rlcs(i));
    
end

%% Plot Result

figure();
plot(tm,dt,'LineWidth',2);
hold on
scatter(plcs,pwv,'filled');
hold on
scatter(rlcs,qrs,'filled');
hold on
scatter(tlcs,twv,'filled');
grid on; grid minor;
legend('ECG','Pwv','QRS','Twv');

end