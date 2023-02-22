function [stack, stack_hor, header, header_hor] = get_features_GPL_v2(a, fs, plt, t_0, t_TO)
% Function that should be used considering an acceleration matrix with filtered data
% Input variables: - a: filtered accelerometer signal of a SLJ obtained
%                      using Phyphox app. It is a matrix with 3 columns
%                      containing respectively x, y, z components
%                  - fs: sampling frequency
%                  - plt: 0/1, to plot (1) of not (0) the velocity vertical
%                        component and the transition timings
%                  - t_0: onset time instant in frames
%                  - t_TO: take-off time instant in frames
% Output variables: - stack: array containing vertical features
%                   - stack_hor: array containing horizontal features
%                   - header: list of vertical features names
%                   - header_hor: list of horizontal features names
% WARNING: vertical features are reported with the names as they are or
% with the name followed by "Vert". Horizontal features are reported with
% the name followed by "_hor" or "Hor" or "H".

% VERSION: 31/07/2022%
%
g = 9.80665;
a_vert=-a(:,1);

% -- VMD Parameters -- %
alpha = 100;        % Mid Bandwidth Constrain  
tau = 0;            % Noise-tolerance (no strict fidelity enforcement)  
K = 3;              % 3 IMFs  
DC = 0;             % DC part not imposed  
init = 0;           % Initialize omegas uniformly  
tol = 1e-6;        % Tolerance parameter

[u, u_hat, omega] = vmd(a_vert, alpha, tau, K, DC, init, tol);

cf = omega(end,:) * fs/2;
f3 = cf(1); f2 = cf(2); f1 = cf(3);

% t_0
% 2. Unweighting Phase 
%         thr_t0 = 8 * std(a_filt(1 : fs));
%         for k = 1 : length(a) - 1
%             if ( -a_filt(k) > thr_t0 )
%                 t_02 = k - round(0.03 * fs);
%                 break
%             end
%         end

% Compute Velocity from "onset"
t = linspace(0, (length(a_vert) - t_0) / fs, (length(a_vert) - t_0));
vt = cumtrapz(t, a_vert(t_0 : end - 1));

% fill v with zeros to match a shape
v = [zeros(t_0,1); vt];

% The end of (U) occurs when, after the Onset, the BW > 0 <==> a > 0 <==>
% <==> v is at local minimum

%%for ss = t_0 + 30 : length(v) - 1
%%    if v(ss) > v(ss+1)
%%      t_UB = ss + 30 - 1;
%%      break
%%    endif
%%end

% Add condition avoiding drift-related errors. It could happen that, when the 
% integral drifts towards the end due to numerical errors/subject not landing 
% on the FP properly, that the maximum velocity is reached way too late. 
% The idea is to bound the computation of maximum to the minimum velocity value,
% which occurs briefly after the landing instant.

[~, stop_smpl] = min(v);

[~, vM] = max(v( 1 : stop_smpl ));
[~, vm] = min(v( t_0 : vM));
t_UB = vm + t_0 - 1;

if isempty(t_UB)
    [~, t_UB] = min(v( t_0 : t_TO));
    t_UB=t_UB+t_0-1;
end

figure;
title('UB');
plot(v);
hold on;
plot(t_UB, v(t_UB),'*');
pause

% 3. Breaking Phase
% Find the first sample such that v > 0
for k = t_UB : length(a_vert)
    if v(k) > 0
        t_BP = k;
        break
    end
end

% 4. Propulsion Phase
% From BP to "end", find the first k : a[k] < -g
%         flag = false;
%         for k = t_BP : length(a)
%             if a(k) <= -g
%                 t_TO = k;
%                 flag = true;
%                 break
%             end
%         end
%         
%         if flag == false
%            [~, vm] = max(v);
%            [~, am] = min(a(vm:vm+30))
%            t_TO2 = vm + am - 1;
%            flag = true;
%         end

% Power
cnt = 1;
for k = t_0 : t_TO
    P_tmp(cnt,1) = (a_vert(k) + g) * v(k);
    cnt = cnt + 1;
end
P = [zeros(t_0,1); P_tmp];

% Height
h = .5 * v(t_TO)^2 / g;

%% Jump Vertical Features
% -- A -- %
A = (t_UB - t_0) / fs;

% -- b -- %
b = min(a_vert(t_0 : t_BP));

% -- C -- %
[~, a_min] = min(a_vert(t_0 : t_BP));
[~, a_max] = max(a_vert(t_0 : t_TO));
C = (a_max - a_min) / fs;

% -- D -- %
% for k = t_UB : t_TO
%     if a(k) < 0
%         F_0 = k - 1;
%         break
%     end
% end
% D = (F_0 - t_UB) / fs;
for k = t_TO : -1 : t_UB
    if a_vert(k) >= 0
        F_0 = k + 1;
        break
    end
end
D = (F_0 - t_UB) / fs;


% -- e -- %
e = max(a_vert(t_0 : t_TO));

% -- F -- %
F = (t_TO - a_max) / fs;

% -- G -- %
G = (t_TO - t_0) / fs;

% -- H -- %
H = (t_BP - a_min) / fs;

% -- i -- %
tilt = diff(a_vert(a_min : a_max + 1));
[~, tilt_max] = max(tilt);
i = a_vert(t_0 + a_min + tilt_max);

% -- J -- %
[~, v_min] = min(v(1 : t_BP));
J = (t_BP - v_min) / fs;

% -- k -- %
k1 = a_vert(t_BP);

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
shape = trapz(time, a_vert(t_UB : F_0 - 1));
q = shape / (D * e);

% -- r -- %
r = b / e; 

% -- s -- %
[~, v_max] = max(v);
s = min(v(1 : v_max));

% -- t -- %
t = mean(P(t_0 : t_BP));

% -- u -- %
u = mean(P(t_BP : t_TO));

% -- W -- %
[~, P_min] = min(P(1 : P_max));
W = (P_max - P_min) / fs;


% Table
header = {'h', 'A', 'b', 'C', 'D', 'e', 'F', 'G', 'H', 'i', 'J', 'k', 'l', 'M',...
    'n', 'O', 'p', 'q', 'r', 's', 't', 'u', 'W', 'f3', 'f2', 'f1'};

stack = [h, A, b, C, D, e, F, G, H, i, J, k1, l, M, n, O, p, q, r, s, t, u, W,...
    f3, f2, f1];

T = array2table(stack, 'VariableNames', header);

if plt == 1
    figure
    plot(v); hold;
    plot(t_0, v(t_0), 'or');
    plot(t_UB, v(t_UB), '*'); 
    plot(t_BP, v(t_BP), '+');
    plot(t_TO, v(t_TO), 'og');
    title('Transition timings');
end
pause


%% Jump Horizontal Features
a_hor= a(:,2);

% Compute Velocity from "onset"
t = linspace(0, (length(a_hor) - t_0) / fs, length(a_hor) - t_0);
vt_hor = cumtrapz(t, a_hor(t_0 : end - 1));
% fill v with zeros to match a shape
v_hor = [zeros(t_0,1); vt_hor];

figure
plot(v_hor); hold;
plot(t_0, v_hor(t_0), 'or');
plot(t_UB, v_hor(t_UB), '*'); 
plot(t_BP, v_hor(t_BP), '+');
plot(t_TO, v_hor(t_TO), 'og');
title('Transition timings in AP signal');

% -- b1 -- %
b1 = min(a_hor(t_0 : t_TO));

% -- C1 -- %
[~, a_min_hor] = min(a_hor(t_0 : t_TO));
[~, a_max_hor] = max(a_hor(t_0 : t_TO));
C1 = abs(a_max_hor - a_min_hor) / fs;

% -- D1 -- %
% for k = t_UB : t_TO
%     if a(k) < 0
%         F_0 = k - 1;
%         break
%     end
% end
% D = (F_0 - t_UB) / fs;
for k = t_TO : -1 : t_UB
    if a_hor(k) >= 0
        F_0 = k + 1;
        break
    end
end
D1 = (F_0 - t_UB) / fs;

% -- D2 --%
for k = t_TO : -1 : t_0
    if a_hor(k) >= 0
        F_1 = k + 1;
        break
    end
end
D2 = (F_1 - t_UB) / fs;

% -- e1 -- %
e1 = max(a_hor(t_0 : t_TO));

% -- F1 -- %
F1 = (t_TO - a_max_hor) / fs;

% -- H1 -- %
H1 = abs(t_BP - a_min_hor) / fs;

% -- i1 -- %
        % tilt = diff(a_hor(a_min_hor : a_max_hor + 1));
        % [~, tilt_max] = max(tilt);
        % i1 = a_hor(t_0 + a_min_hor + tilt_max);

% -- J1 -- %
[~, v_min_hor] = min(v_hor(1 : t_BP));
J1 = (t_BP - v_min_hor) / fs;

% -- k2 -- %
k2 = a_hor(t_BP);

% Power
cnt = 1;
for k = t_0 : t_TO
    P_tmp(cnt,1) = (a_hor(k)) * v_hor(k);
    cnt = cnt + 1;
end
P_hor = [zeros(t_0,1); P_tmp];

% -- l -- %
l1 = min(P_hor(t_UB : t_BP));

% -- M -- %
flag = false;
for k = t_BP + 3 : length(P_hor)
    if P_hor(k) < 0
        P_0_hor = k-1;
        flag = true;
        break
    end
end
% Correct for too much wiphlash
if flag == false
    P_0_hor = length(P_hor);
end
M1 = (P_0_hor - t_BP) / fs;

% -- M2 -- %
flag = false;
for k = t_0 : length(P_hor)
    if P_hor(k) < 0
        P_0_totH = k-1;
        flag = true;
        break
    end
end
% Correct for too much wiphlash
if flag == false
    P_0_totH = length(P_hor);
end
M2 = (P_0_totH - P_0_hor) / fs; % dovrebbe essere tutta la potenza positiva


% -- n1 -- %
n1 = max(P_hor);

% -- O1 -- %
[~, P_max_hor] = max(P_hor);
O1 = (t_TO - P_max_hor) / fs;

% -- p1 -- %
p1 = (e1 - b1) / C1;

% -- q -- %
time = linspace(0, (F_0 - t_UB) / fs, (F_0 - t_UB));
shape_hor = trapz(time, a_hor(t_UB : F_0 - 1));
q1 = shape_hor / (D1 * e1);

% -- r -- %
r1 = b1 / e1; 

% -- s -- %
[~, v_max_hor] = max(v_hor);
s1 = min(v_hor(1 : v_max_hor));
s2 = min(v_hor(1 : t_TO));
% -- t -- %
t1 = mean(P_hor(t_0 : t_BP));

% -- u -- %
u1 = mean(P_hor(t_BP : t_TO));

% -- W -- %
[~, P_min_hor] = min(P_hor(1 : P_max_hor));
W1 = (P_max_hor - P_min_hor) / fs;

[~, P_min_hor1] = min(P_hor(1 : t_TO));
W2 = abs(P_max_hor - P_min_hor1) / fs;

% -- VMD Parameters -- %
alpha = 100;        % Mid Bandwidth Constrain  
tau = 0;            % Noise-tolerance (no strict fidelity enforcement)  
K = 3;              % 3 IMFs  
DC = 0;             % DC part not imposed  
init = 0;           % Initialize omegas uniformly  
tol = 1e-6;        % Tolerance parameter

[u_hor, u_hat_hor, omega_hor] = vmd(a_hor, alpha, tau, K, DC, init, tol);

cfH = omega_hor(end,:) * fs/2;
f3H = cfH(1); f2H = cfH(2); f1H = cfH(3);

%% Temporal features
t_TOBP= (t_TO-t_BP)/fs;
deltaAccVert= max(a_vert(t_0:t_TO))- min(a_vert(t_0:t_TO));
deltaVelVert= max(v(t_0:t_TO))- min(v(t_0:t_TO));
deltaAccHor= max(a_hor(t_0:t_TO))- min(a_hor(t_0:t_TO));
deltaVelHor= max(v_hor(t_0:t_TO))- min(v_hor(t_0:t_TO));

% Horizontal features and temporal features
header_hor = {'bH', 'CH', 'DH', 'D2H', 'eH', 'FH', 'HH', 'JH', 'kH', 'lH', 'MH','M2H',...
    'nH', 'OH', 'pH', 'qH', 'rH', 'sH', 's2H','tH', 'uH', 'WH','W2H', 'f3H','f2H','f1H','t_TOBP','deltaAccVert','deltaVelVert','deltaAccHor','deltaVelHor'};

stack_hor = [b1, C1, D1, D2, e1, F1, H1, J1, k2, l1, M1, M2, n1, O1, p1, q1, r1, s1, s2, t1, u1, W1, W2, f3H, f2H, f1H, t_TOBP, deltaAccVert, deltaVelVert,deltaAccHor,deltaVelHor];

% T = array2table([stack stack_hor], 'VariableNames', [header header_hor]);

end