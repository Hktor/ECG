%   File: Loads ECG raw data from gTech recording device and stores it in a struct
%   Author: Hector Alvarez
%   
% Draft, 20170829, reto.wildhaber@bfh.ch


close all; clear all; clc;
IN_PATH  = './data/Raw/'; % Default path for input files
OUT_PATH = './data/Processed/'; % Default path for output files

% Load Header File
[fnm,path,~] = uigetfile({'*.hea','HEA (*.hea)'},'Load Header File..', IN_PATH);
inFile = [path fnm];

fid = fopen(inFile,'r');

inf = false;

rcrd = false;
nOfS = false;

feld = 0;

age = nan;
sex = nan;
dtm = nan;
smk = false;
diagnose = '';

while ~feof(fid)
    tline = fgetl(fid);
    if ~contains(tline,'#') && ~inf
        entry = strfind(tline,' ');
        entry(end+1) = size(tline,2);
        
        idx1 = 1;
        idx2 = -1;

        for i = 1:size(entry,2)
            idx2 = entry(i)-1;
            switch (feld)
                case 0 
                    rcrd = tline(idx1:idx2); % Record
                case 1 
                    nOfS = tline(idx1:idx2); % Num of Signals
                case 2
                    fs = tline(idx1:idx2);   % Sampling Frequency
                case 3
                    dura = tline(idx1:idx2); % Duration
            end
            feld = feld + 1;
            idx1 = entry(i)+1;
        end
    else
        
        if strfind(tline,'# age:') ~=0
                age = tline(8:end); % Age of the patient
        elseif strfind(tline,'# sex:') ~=0
                sex = tline(8:end); % Sex of the patient
        elseif strfind(tline,'# ECG date:') ~=0
                dtm = tline(13:end); % Date of record
        elseif strfind(tline,'Smoker') ~=0
                smk = true;             % Smoker
        elseif strfind(tline,'# Reason for admission:') ~=0
                diagnose = tline(25:end); % Diagnosis
        end
    end

end

ptID = findPatientID (rcrd);

ecg = struct();

ecg.info.record = rcrd;
ecg.info.patient = ptID;
ecg.info.nOfS = str2num(nOfS);
ecg.info.duration = str2double(dura);

ecg.info.age = str2num(age);
ecg.info.sex = sex;
ecg.info.date = dtm;
ecg.info.smoker = smk;

ecg.info.diagnose = diagnose;

% Load Data File
fnm = strcat(rcrd, '.mat'); 
inFile = [path fnm];
load(inFile);

ecg.config.fs = str2num(fs);
ecg.config.tmStep = 1/ecg.config.fs;
ecg.config.labels = {'i' 'ii' 'iii' 'avr' 'avl' 'avf' 'v1' 'v2'...
                    'v3' 'v4' 'v5' 'v6' 'vx' 'vy' 'vz'};

ecg.data.val = val;
ecg.data.nOfSmp = size(val,2);
tm = 0:ecg.config.tmStep:ecg.data.nOfSmp/ecg.config.fs;
ecg.data.tm = tm(1:end-1);

outFilename = strcat(OUT_PATH, ptID, '.mat'); 
save(outFilename, 'ecg','ecg');

fprintf(sprintf('Record successfully stored: %s\n', outFilename));

          