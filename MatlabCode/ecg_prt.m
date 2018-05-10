
%% ecg_prt.m
%
% Author: Hector Alvarez
% Date: 10.05.2018
%
% This script will execute the analysis of ECG records.
% Its function is to identify the Pwave, QRS-complex, 
% and Twave for any given HR.
%
% Procedure:
%       1. Average window for 100 milliseconds
%       2. Extract waves with a frequency of 20 Hz - filtering
%       3. Extract wave with a frequency of 1Hz (Cardiac Cycle)
%       4. Compute peaks from 1Hz signal - finding Pwave and Twave
%           4.1 Minimum points = Pwave
%           4.2 Maximum points = Twave
%       5. Compute peaks from 20Hz signal - finding QRS-complex
%           5.1 Remove Pwave and Twave peaks
%           5.2 Identify peaks between Pwave and Twave (QRS)
%       6. Plot results
%   
% Input: ECG file stored in a folder ./Processed/
%
% Output: Graphics stored in the folder ./Results/...
%
%%

%% **************************** Load Data *********************************

% Initialize
close all; clear all; clc;
IN_PATH = './Processed/'; % Default path for input files
addpath('./utils');

% Load ECG Raw Data File
[fnm,path,~] = uigetfile({'*.mat','MAT (*.mat)'},'Load ECG File..', IN_PATH);
inFile = [path fnm];
load(inFile);

fname = ecg.info.patient;
fdate = ecg.info.date;
fdate(fdate=='/') = [];
fdura = ecg.info.duration;

fprintf(sprintf('File Loaded: %s\n', fnm));

% Create Output Directory

PATH_ROOT = sprintf('./Results/%s/%s/%s',fname,fdate,fdura);
status = exist(PATH_ROOT,'dir');
if  status > 0
    % **************** Clean Data if results already exits ****************
    rmdir (PATH_ROOT,'s');
end

mkdir (PATH_ROOT);

fprintf('Directories Succesfully Created\n');

%% Time, and period Definition

tm     = ecg.data.tm;
tm     = tm';
data    = ecg.data.val;
data    = data';
nOfE    = ecg.info.nOfE;
periodStart = ceil(tm(1)); % Initial Time
periodFinal = ceil(tm(end)); % Final time
tmPeriod  = periodStart:1:periodFinal-1;
tmPeriod  = tmPeriod';

fs = ecg.config.fs;                            

%% Filter ECG and find PRT
dwFactor = 4;
dwfs = fs/dwFactor;

% Outputs: Frequency Filter, Features Filter
p_data = zeros(nOfE,nOfE);
q_data = zeros(nOfE,nOfE);
t_data = zeros(nOfE,nOfE);

for ch=1:nOfE
    
    % LOAD DATA
    
    dt = data(:,ch);
    
    % Find Pwave, QRS-complex, Twave
       
    [plcs,qlcs,tlcs] = find_PQT(dt,fs,tm);
    
    % Store Individual Channel into Array
    p_data(1:size(plcs),ch) = plcs;
    q_data(1:size(qlcs),ch) = qlcs;
    t_data(1:size(tlcs),ch) = tlcs;
    
end
