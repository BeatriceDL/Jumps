function [t_0, t_TO, v,vmax,a] = get_timings_v2(a, fs)
g = 9.80665;

% Onset
% 2. Unweighting Phase 
thr_t0 = 8 * std(a(1 : fs));
for k = 1 : length(a) - 1
    if ( -a(k) > thr_t0 )
        t_0 = k - round(0.03 * fs);
        break
    end
end

% Compute Velocity from "onset"
t = linspace(0, (length(a) - t_0) / fs, length(a) - t_0);
vt = cumtrapz(t, a(t_0 : end - 1));

% Fill v with zeros to match a shape
v = [zeros(t_0,1); vt];

% Take-Off
% Find maximum index in velocity, then start finding the TO in acc from
% that index. TO will be few samples after vmax, when a <= -g.

%AGGIUNTA: max(v) sulla prima metà del salto
[v1, vmin1] = min(v); j=1;
vmin2=v(islocalmin(v));
secondo_minimo=max(vmin2);
for i=1:length(vmin2)
    if (vmin2(i)<secondo_minimo(end)) && (vmin2(i)~=v1)
        secondo_minimo(j)=vmin2(i);
        j=j+1;
    end
end

loc_second_min=find(v==secondo_minimo);
for i=1:length(loc_second_min)
    if (vmin1<v(loc_second_min(i))) && ((v(loc_second_min(i)))-vmin1>3)
        vmin=find(v==secondo_minimo);
        [~, vmax] = max(v(1:vmin)); % Find maximum index
        break;
    elseif (vmin1>v(loc_second_min(i))) && (vmin1-v(loc_second_min(i))>3)
        vmin=vmin1;
        [~, vmax] = max(v(1:vmin)); % Find maximum index
        break;
    end
end


flag = false;
for k = vmax : length(a)
    if a(k) <= -g
        t_TO = k;
        flag = true;
        break
    end
end

figure; 
plot(v);
title('T_TO'); hold on; plot(t_TO,v(t_TO),'+')



end