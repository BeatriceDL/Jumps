%% GET FEATURES
% ------------------------------------------------------------------------
% Description: Main script used to extract biomechanically- and frequency-
% related features on countermovement jumps acquired through
% smartphone-IMU.
% The features are the ones proposed in [1] and [2].
% ------------------------------------------------------------------------
% Author: Guido Mascia, MSc, PhD student at University of Rome "Foro
% Italico", Rome, Italy. -- mascia.guido@gmail.com
% First Commit: 08.03.2022
% Last modified: 08.03.2022
% ------------------------------------------------------------------------
% References:
% [1] Mascia, G., & Camomilla, V. (2021). An automated Method for the
% Estimate of Vertical Jump Power through Inertial Measurement Units.
% ISBS Proceedings Archive, 39(1). https://commons.nmu.edu/isbs/vol39/iss1/74
% [2] Dowling, J. J., & Vamos, L. (1993). Identification of Kinetic and
% Temporal Factors Related to Vertical Jump Performance. Journal of
% Applied Biomechanics, 9(2), 95–110. https://doi.org/10.1123/jab.9.2.95
% ------------------------------------------------------------------------

g = 9.80665;
fs = 128;

data = csvread('sp.csv');   % Read Data
acc = data(:,1:3); gyr = data(:,4:6); 

% Align to Global Reference Frame and Remove Gravity consistently
a = do_align(acc, gyr, fs);

a_filt = bwfilt(a, 6, fs, 50, 'low');   % Remove sensor noise "proper"

% -- VMD Parameters -- %
alpha = 100;        % Mid Bandwidth Constrain
tau = 0;            % Noise-tolerance (no strict fidelity enforcement)
K = 3;              % 3 IMFs
DC = 0;             % DC part not imposed
init = 0;           % Initialize omegas uniformly
tol = 1e-6;        % Tolerance parameter

[~, u_hat, omega] = vmd(a, alpha, tau, K, DC, init, tol);

cf = omega(end,:) * fs/2;
f3 = cf(1); f2 = cf(2); f1 = cf(3);

% t_0
% 2. Unweighting Phase
thr_t0 = 8 * std(a_filt(1 : fs));
for k = 1 : length(a) - 1
    if ( -a_filt(k) > thr_t0 )
        t_0 = k - round(0.03 * fs);
        break
    end
end

% Compute Velocity from "onset"
t = linspace(0, (length(a) - t_0) / fs, length(a) - t_0);
vt = cumtrapz(t, a(t_0 : end - 1));
% fill v with zeros to match a shape
v = [zeros(t_0,1); vt];

% The end of (U) occurs when, after the Onset, the BW > 0 <==> a > 0 <==>
% <==> v is at local minimum

% Add condition avoiding drift-related errors. It could happen that, when the
% integral drifts towards the end due to numerical errors/subject not landing
% on the FP properly, that the maximum velocity is reached way too late.
% The idea is to bound the computation of maximum to the minimum velocity value,
% which occurs briefly after the landing instant.

[~, stop_smpl] = min(v);

[~, vM] = max(v( 1 : stop_smpl ));
[~, vm] = min(v( t_0 : vM));
t_UB = vm + t_0 - 1;

% 3. Breaking Phase
% Find the first sample such that v > 0
for k = t_UB : length(a)
    if v(k) > 0
        t_BP = k;
        break
    end
end

% 4. Propulsion Phase
% From BP to "end", find the first k : a[k] < -g
flag = false;
for k = t_BP : length(a)
    if a(k) <= -g
        t_TO = k;
        flag = true;
        break
    end
end

if flag == false
    [~, vm] = max(v);
    [~, am] = min(a(vm:vm+30))
    t_TO = vm + am - 1;
    flag = true;
end

% Power
cnt = 1;
for k = t_0 : t_TO
    P_tmp(cnt,1) = (a(k) + g) * v(k);
    cnt = cnt + 1;
end
P = [zeros(t_0,1); P_tmp];

% Height
h = .5 * v(t_TO)^2 / g;

%% Jump Features -- See [2]
% -- A -- %
A = (t_UB - t_0) / fs;

% -- b -- %
b = min(a(t_0 : t_BP));

% -- C -- %
[~, a_min] = min(a(t_0 : t_BP));
[~, a_max] = max(a(t_0 : t_TO));
C = (a_max - a_min) / fs;

for k = t_TO : -1 : t_UB
    if a(k) >= 0
        F_0 = k + 1;
        break
    end
end
D = (F_0 - t_UB) / fs;


% -- e -- %
e = max(a(t_0 : t_TO));

% -- F -- %
F = (t_TO - a_max) / fs;

% -- G -- %
G = (t_TO - t_0) / fs;

% -- H -- %
H = (t_BP - a_min) / fs;

% -- i -- %
tilt = diff(a(a_min : a_max + 1));
[~, tilt_max] = max(tilt);
i = a(t_0 + a_min + tilt_max);

% -- J -- %
[~, v_min] = min(v(1 : t_BP));
J = (t_BP - v_min) / fs;

% -- k -- %
k1 = a(t_BP);

% -- l -- %
l = min(P(t_UB : t_BP));

% -- M -- %
flag = false;
for k = t_BP + 3 : length(P)
    if P(k) < 0
        P_0 = k-1;
        flag = true;
        break
    end
end

% Correct for too much wiphlash
if flag == false
    P_0 = length(P);
end
M = (P_0 - t_BP) / fs;

% -- n -- %
n = max(P);

% -- O -- %
[~, P_max] = max(P);
O = (t_TO - P_max) / fs;

% -- p -- %
p = (e - b) / C;

% -- q -- %
time = linspace(0, (F_0 - t_UB) / fs, (F_0 - t_UB));
shape = trapz(time, a(t_UB : F_0 - 1));
q = shape / (D * e);

% -- r -- %
r = b / e;

% -- s -- %
[~, v_max] = max(v);
s = min(v(1 : v_max));

% -- u -- %
u = mean(P(t_BP : t_TO));

% -- W -- %
[~, P_min] = min(P(1 : P_max));
W = (P_max - P_min) / fs;

% -- z -- %
z = mean(P(t_0 : t_BP));

% Stack Features
stack = [h, A, b, C, D, e, F, G, H, i, J, k1, l, M, n, O, p, q, r, s, u, W, z,...
    f3, f2, f1];

figure
plot(a); hold;
plot(t_0, a(t_0), '*r');
plot(t_UB, a(t_UB), '*r');
plot(t_BP, a(t_BP), '*r');
plot(t_TO, a(t_TO), '*r');
title('Transition timings');
