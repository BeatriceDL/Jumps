function D = readPhyphox_v2(filename, align, filter)
%READPHYPHOX_V2 is a function that reads the sheets from .xls file exported by Phyphox
%Input variables:   - filename: name of the .xls file to be imported
%                   - align: 0/1 value, if you want to align (1) or not (0)
%                            the accelerometer and gyroscope
%                   - filter: 0/1 value, if you want to filter (1) or not
%                            (0) the data
%Output variable:   - D: struct that contains the data
acc_t = readcell(filename, 'Sheet', 1);   % Sheet 1 is [t acc]
gyr_t = readcell(filename, 'Sheet', 2);   % Sheet 2 is [t gyr]
mag_t = readcell(filename, 'Sheet', 3);   % Sheet 3 is [t mag]

acc_t = cell2mat(acc_t(2:end,:));
gyr_t = cell2mat(gyr_t(2:end,:));
mag_t = cell2mat(mag_t(2:end,:));

% Separate time vectors from measures
ta = round(acc_t(:,1), 3); tg = round(gyr_t(:,1), 3); tm = round(mag_t(:,1), 3);

% Store sampling frequencies: 1 / ts
fs_a = round(1 / diff(acc_t(2:3,1))); 
fs_g = round(1 / diff(gyr_t(2:3,1)));
fs_m = round(1 / diff(mag_t(2:3,1)));

% Realign timings for all the sensors
if align == 0
    display('You have chosen to maintain original timings. Be careful!')

    D.acc = acc_t(:,2:end); D.gyr = gyr_t(:,2:end); D.mag = mag_t(:,2:end); 
    D.ta = acc_t(:,1); D.tg = gyr_t(:,1); D.tm = mag_t(:,1);
    D.fs_a = fs_a; D.fs_g = fs_g; D.fs_m = fs_m;
    
elseif align == 1
    
    display('Data will be aligned.')
    % Find the common values for 'ta' and 'tg'
    [val1, pos1] = intersect(ta, tg);
    [val2, pos2] = intersect(tg, ta);
    
    if val1==val2
        for i=1:length(ta)-1
            if ta(i+1) == ta(i)
            else
                ta=ta(i:end);
                break;
            end
        end
        for i=1:length(tg)-1
            if tg(i+1) == tg(i)
            else
                tg=tg(i:end);
                break;
            end
        end
        [val1, pos1] = intersect(ta, tg);
        [val2, pos2] = intersect(tg, ta);
    end

    % Find the position in 'tg' for which it is equal to 'ta( pos(1) )',
    % then compute the 'shift'
    shift = pos1(1) - pos2(2) + 2;

    if shift > 0
        acc_temp = acc_t(shift : end,:);
        gyr_temp = gyr_t;
    elseif shift < 0
        gyr_temp = gyr_t(-shift : end,:);
        acc_temp = acc_t;
    end
    
    La = size(acc_temp, 1);
    Lg = size(gyr_temp, 1);

    if La <= Lg   
        acc_t = acc_temp;
        gyr_t = gyr_temp(1:La,:);
    elseif Lg < La
        acc_t = acc_temp(1:Lg,:);
        gyr_t = gyr_temp;
    end
    
    % Store sampling frequencies: 1 / ts
    fs_a = round(1 / diff(acc_t(2:3,1))); 
    fs_g = round(1 / diff(gyr_t(2:3,1)));
    fs_m = round(1 / diff(mag_t(2:3,1)));
    
    
    %% MAGNETOMETER TO BE WRITTEN YET
    % The magnetometer should be of a different fs. Moreover, it is
    % misaligned.    
    %% Filter Signal
    if filter == 1
        [b,a] = butter(6, 10/fs_a, 'low');
        acc_t(:,2:end) = filtfilt(b,a,acc_t(:,2:end));
        gyr_t(:,2:end) = filtfilt(b,a,gyr_t(:,2:end));
    end

    %% Store data
    D.acc = acc_t(:,2:end); D.gyr = gyr_t(:,2:end); D.mag = mag_t(:,2:end);
    D.ta = acc_t(:,1); D.tg = gyr_t(:,1); D.tm = mag_t(:,1);
    D.fs_a = fs_a; D.fs_g = fs_g; D.fs_m = fs_m;
    
else
        display('align should be either 0 (no alignemnt) or 1 (alignment).')
end
   
    display('All data succesfully stored.')
    display(['Accelerometer fs = ' num2str(fs_a) ' Hz'])
    display(['Gyroscope fs = ' num2str(fs_g) ' Hz'])
    display(['Magnetometer fs = ' num2str(fs_m) ' Hz'])
end