function [L, features,header, header_hor, T] = estimate_jump_v2(default_folder,folderPath, subject, jump, cutting, filtering)
% Function that estimate jump lenght, based on test_script
% Input variables: - default_folder: 0/1, to indicate if the data
%                                    are in the current folder (0) or not
%                                    (1)
%                  - folderPath: string variable to indicate the path if
%                                data are stored in a different folder
%                  - subject: folder of the subject
%                  - jump: name of the .xls file containing the data coming
%                          from Phyphox app. In this work each subject
%                          performed more than one jump, for this reason
%                          the file is named following the number of jumps
%                  - cutting: 0/1, to indicate if the signal has to be cut
%                             (1) or not (0) before data processing
%                  - filtering: 0/1, to indicate if the signal has to be
%                               filtered (1) or not (0)
% Output variables: - L: b_jump estimated feature
%                   - features: matrix containing all the features reported
%                               in the article
%                   - header and header_hor: list of strings containing the
%                                            names of the vertical (V) and
%                                            antero-posterior (AP/hor)
%                                            features extracted from the
%                                            Phyphox signal
%                   - T: table containing the features extracted and the
%                        corresponding names
% WARNING: this function works based on sampling frequencies of 500 Hz for
% both accelerometer and gyroscope. Please check and change the sampling
% frequencies values where needed. Calibration step (lines 54-67) is based
% on calibration results obtained following Bergamini et al. (2014)
% article. Please, check the calibration values of your smartphone and
% replace data where needed.
%   DATE: 16/02/2023

%1) FOLDER SELECTION
%   default_folder==0 => another folder is used respect to dataFolder
    if default_folder==0
        folder= [folderPath '\' subject '\SALTO O CON FIANCHI'];
        filename=[folder '/' jump];
    elseif default_folder==1
        folder=['./data'];
        filename=[folder '/' subject '/' jump];
    end


%2) READPHYPHOX
%   Check if Phyphox data are properly loaded from .xls files
    D = readPhyphox_v2(filename, 1, 0); % Align = 1; Filter = 1;
    D.fs_a=500; D.fs_g=500;
%   Plot them
    figure;
    subplot(211); plot(D.ta, D.acc); title('Accelerometer'); xlabel('Time (s)'); ylabel('Acceleration (m/s^2)')
    subplot(212); plot(D.tg, D.gyr); title('Gyroscope'); xlabel('Time (s)'); ylabel('Angular Velocity (rad/s)')
    pause; close;


%3) CALIBRATION APPLICATION
%   Accelerometer
    Cs=[0.9968 -0.0083 0.0020; 0.0058 1.0033 0.0011; 0.0010 -0.0083 0.9962];
    a_zero=[-0.0012; -0.0048; -0.00053272];
    D.acc=Cs*(D.acc'-a_zero);
    D.acc=D.acc';

%   Gyroscope
    D.gyr= D.gyr*180/pi;
    Cs_gyro=[1.1094 -0.0142 0.0039; 0.0138 1.0024 -0.0013; -0.0063 0.00036030 0.9913];
    w_zero= [0.0286; 0.0137; -0.0077];
    D.gyr= Cs_gyro*(D.gyr'-w_zero);
    D.gyr= D.gyr';
    D.gyr= D.gyr*pi/180;

%4) CUT SIGNAL
    if cutting==1
        figure
        plot(D.gyr);
        title("Cut signal")
        [new_x, ~] = ginput(2); 
        close
        new_x = round(new_x);
        D.gyr=D.gyr(new_x(1):new_x(2),:);
        D.acc=D.acc(new_x(1):new_x(2),:);
    end

%5) Gyroscope Static Bias Removal
%   Select a static window via 'ginput', then compute mean and subtract it to
%   the whole signal
    figure;
    plot(D.gyr);
    title("Select a window to remove bias gyroscope")
    [x, ~] = ginput(2); 
    close
    x = round(x); 
    
%   Store into D
    D.gyr_bias = mean(D.gyr(x(1):x(2), :));
    D.gyr_calib = D.gyr - D.gyr_bias;

%   Plot each axis
    figure;
    ax_n = {'X', 'Y', 'Z'}; % Axes names
    for i = 1 : size(D.gyr,2)
    
        subplot(3,1,i); plot([D.gyr(x(1):x(2),i) D.gyr_calib(x(1):x(2),i)])
        title([string(ax_n(i)) '-Axis'])
    
    end
    legend('Biased', 'Calibrated')
    pause
    close


%6) Align with World Coordinate System and remove bias of accelerometer
    a_glob = do_align_v2(D.acc, D.gyr, D.fs_a, 0);

    % Plot each axis
    for i = 1 : size(D.acc,2)
        
        subplot(3,1,i); plot([D.acc(:,i), a_glob(:,i)])
        title([string(ax_n(i)) '-Axis'])
    
    end

%7) FILTERING
if filtering==1
    [b,c]=butter(4,30/250,"low");
    a_glob=filtfilt(b,c,a_glob);
end


%8) EXTRACT FEATURES

% Velocity, t_0, t_TO
[t_0, t_TO, v,vmax] = get_timings_v2(-a_glob(:,1), D.fs_a);

% Plot of timings 
figure;
plot(v);
title('V max');
hold on;
plot(vmax,v(vmax),'o');
pause
figure; plot(-a_glob(:,1))
title("t_0 e T_TO")
hold on;
plot([t_0, t_TO], -a_glob([t_0, t_TO],1), 'or')

% Time vector
t = linspace(0, (length(a_glob) - t_0)/ D.fs_a, (length(a_glob) - t_0));
vy = [zeros(t_0,1); cumtrapz(t, -a_glob(t_0:end-1, 1))]; % vertical velocity 
vx = [zeros(t_0,1); cumtrapz(t, a_glob(t_0:end-1, 2))]; % horizontal velocity

close all
figure;
plot([vx, vy])
title("Velocità x e y")
legend

% b_jump estimation
v0x = vx(t_TO); v0y = vy(t_TO);
[t, L] = jump_estimate(v0x, v0y)

%Get features%
[stack_vert, stack_hor, header, header_hor] = get_features_GPL_v2(a_glob, 500, 1, t_0, t_TO);

alfa= atan(v0x/v0y);  %in rad

t_flight= 2*v0y/9.80665;

features.t_0=t_0;
features.t_TO=t_TO;
features.stack_vert=stack_vert;
features.stack_hor=stack_hor;
features.alfa=alfa;
features.t_flight=t_flight;

% Table creation
T = array2table([stack_vert stack_hor t_flight alfa L*100], 'VariableNames', [header header_hor "t_flight" "alfa" "b_jump"]);

end