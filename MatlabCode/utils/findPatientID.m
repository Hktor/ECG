function ptID = findPatientID (rcrd)
    switch (rcrd)
        case 's0010_rem'
            ptID = 'ID01_01';
        case 's0014lrem'
            ptID = 'ID01_02';
        case 's0016lrem'
            ptID = 'ID01_03';
        case 's0015lrem'
            ptID = 'ID02';
        case 's0017lrem'
            ptID = 'ID03';
        case 's0020arem'
            ptID = 'ID04_01';
        case 's0020brem'
            ptID = 'ID04_02';
        case 's0021arem'
            ptID = 'ID05_01';
        case 's0021brem'
            ptID = 'ID05_02';
        case 's0025lrem'
            ptID = 'ID05_03';
        case 's0031lrem'
            ptID = 'ID05_03';
        case 's0101lrem'
            ptID = 'ID05_04';
        case 's0022lrem'
            ptID = 'ID06_01';
        case 's0027lrem'
            ptID = 'ID06_02';
        case 's0026lrem'
            ptID = 'ID07_01';
        case 's0029lrem'
            ptID = 'ID07_02';
        otherwise
            ptID = 'NA';
    end
end