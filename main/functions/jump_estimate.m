function [time_h,bjump] = jump_estimate(v_0x,v_0y)
%JUMP_ESTIMATE is a function realized for the evaluation of bjump feature, following the 
%hypothesis that SLJ is follows a projectile motion.

% Input variables:
%   v_0x= horizontal velocity at the take-off
%   v_0y= vertical velocity at the take-off

% Output variables:
%   time_h = time spent to arrive to the Maximum height of projectile
%   bjump =  range in the horizontal plane


g= 9.80665;

time_h = (1+sqrt(2))*v_0y/g;

bjump =abs(2*v_0x*time_h); %perché in alcuni casi per il drift v0x o v0y sono negative
end