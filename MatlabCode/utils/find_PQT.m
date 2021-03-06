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
function [dx_dt,hr_dt] = find_PQT(dt,fs,tm, PATH_ROOT)
fprintf('LowBandPass Filtering...\n');

sz = size(dt,1);        % Size of the data vector

%% Average data in 100 milliseconds - filtering

fi = 12.5;              % Frequency 5 Hz = avg 80ms
p = 1/(fi*2);           % Period length
t = 0:1/fs:p;           % Time vector for filter
t = t(1:end-1);         % Remove last component to adjust time vector
h = sin(2*pi*fi*t);     % Create sine wave - filter
ftsz = size(h,2);       % Size of the filter
dly = round(ftsz/2);    % Calculate delay of the filter
avg_dt = conv(dt,h);    % Find correlation filter and data

av_dt = zeros(sz,1);   % Create a new data vector
av_dt((1:end-dly)) = avg_dt(dly+1:sz); % Correct the output delay

av_dt = (av_dt-min(av_dt))/(max(av_dt)-min(av_dt)); % Normalize vector

%% Extract waves - Pwave, QRScomplex, Twave

fi = 6.5;               % Frequency 3 Hz = avg 167ms
p = 1/fi;               % Period length
t = 0:1/fs:p;           % Time vector for filter
t = t(1:end-1);         % Remove last component to adjust time vector
h = sin(2*pi*fi*t);     % Create sine wave - filter
ftsz = size(h,2);       % Size of the filter
dly = round(ftsz/2);    % Calculate delay of the filter
sn_dt = conv(av_dt,h); % Find correlation filter and data

wv_dt = zeros(sz,1);    % Create a new data vector
wv_dt((1:end-dly)) = -sn_dt(dly+1:sz); % Correct the output delay

wv_dt = (wv_dt-min(wv_dt))/(max(wv_dt)-min(wv_dt)); % Normalize vector

%% Apply derivative filter to get tangent slope

dx = [1;-1];            % First order Derivative Filter

dx_dt = conv(wv_dt,dx,'same'); % Apply filter
dx_dt(dx_dt<0) = 0;    % Set negative values to -1

dx_dt = dx_dt/max(dx_dt);

%% Transform waves into Rectangular form

maxVal = 0;
wvFlag = false;
idx1 = 0;

for i=1:size(dx_dt,1)
    if dx_dt(i) > 0 && ~wvFlag
        idx1 = i;
        maxVal = dx_dt(i);
        wvFlag = true;
    elseif dx_dt(i) > 0 && dx_dt(i) > maxVal && wvFlag 
        maxVal = dx_dt(i);
    elseif dx_dt(i) == 0 && wvFlag
        idx2 = i-1;
        dx_dt(idx1:idx2) = maxVal;
        maxVal = 0;
        wvFlag = false;
    end
end
%% Extract Cardiac Rhythm with peaks at representative waves

fi = 1;                 % Frequency 3 Hz = avg 167ms
p = 1/fi;               % Period length
t = 0:1/fs:p;           % Time vector for filter
t = t(1:end-1);         % Remove last component to adjust time vector
h = sin(2*pi*fi*t);     % Create sine wave - filter
ftsz = size(h,2);       % Size of the filter
dly = round(ftsz/2);    % Calculate delay of the filter
krdio1_dt = conv(dx_dt,h);   % Find correlation filter and data
dly = dly*2;
krdio2_dt = conv(krdio1_dt,h);

hr_dt = zeros(sz,1);    % Create a new data vector
hr_dt((1:end-dly)) = -krdio2_dt(dly+1:sz); % Correct the output delay

hr_dt = (hr_dt-min(hr_dt))/(max(hr_dt)-min(hr_dt)); % Normalize vector

%% Up to this point verify solution


dt = (dt-min(dt))/(max(dt)-min(dt));
    
fig1 = figure('units','normalized','outerposition',[0 0 1 1]);
    
ax1 = subplot(5,1,1);
plot(tm,dt,'k','LineWidth',1.5);
legend('Raw Data');
grid on; grid minor;
    
ax2 = subplot(5,1,2);
plot(tm,av_dt,'c','LineWidth',1.5);
legend('Avg Data');
grid on; grid minor;
    
ax3 = subplot(5,1,3);
plot(tm,wv_dt,'b','LineWidth',1.5);
legend('Wave Data');
grid on; grid minor;

ax4 = subplot(5,1,4);
plot(tm,dx_dt,'r','LineWidth',1.5);
legend('Diff Data');
grid on; grid minor;
    
ax5 = subplot(5,1,5);
plot(tm,dx_dt,'r','LineWidth',1.5);
hold on
plot(tm,hr_dt,'m','LineWidth',1.5);
legend(['Diff Data';'Krdc Data']);
grid on; grid minor;
    
linkaxes([ax1,ax2,ax3,ax4,ax5],'x');
xlim([tm(1)+1 round(tm(end))-1]);

% %% Downsampling to create envelope
% dwsmp_dt = wv_dt(1:50:end);
% dwsmp_tm = tm(1:50:end);
% 
% %% Find Peaks In the Averaged Signal
% [pks,lcs,~] = findpeaks(av_dt,tm);

outFilename = '/Results_PRT.fig'; 
figname = [PATH_ROOT outFilename];
saveas(fig1,figname,'fig');

fprintf(sprintf('Results stored in: %s\n', figname));

end