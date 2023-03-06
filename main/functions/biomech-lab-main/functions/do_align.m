%% DO ALIGN 
% The idea is to remove correctly the gravity. To this aim, the technique
% proposed in [3], through which a global vertical acceleration is computed.
% In order to get the acceleration into the WRF, the following steps are required:
%   1. Compute the acceleration quaternion, that is a quaternion composed 
%      by null scalar component () and the accelerometer measure as the 
%      vectorial component:
%                           a_q = [0, ax·i, ay·j, az·k]
%   2. Get the orientation "quaternion" of the entire trial by using the 
%      complementary filter and compute its conjugate, "quaternion_star";
%   3. Apply, for each time sample, the following relationship:
%                           a_glob = quaternion * a_q * quaternion_star
%
% Gravity can now be removed from the vertical component of the 
% acceleration, and we can store it for further computations.
% Notice that "*" denotes a quaternion multiplication.
% ------------------------------------------------------------------------
% Author: Guido Mascia, MSc, PhD Student at University of Rome "Foro
% Italico", Rome, Italy -- mascia.guido@gmail.com
% First Commit: 08.03.2022
% Last Modified: 08.03.2022
% ------------------------------------------------------------------------
% [1] Rantalainen, T., Finni, T., & Walker, S. (2020). Jump height from 
% inertial recordings: A tutorial for a sports scientist. Scandinavian 
% Journal of Medicine & Science in Sports, 30(1), 38–45. 
% https://doi.org/10.1111/sms.13546
% ------------------------------------------------------------------------

function a_glob = do_align(acc, gyr, fs)
        
        AHRS = MadgwickAHRS();
        AHRS.Beta = 0.001; AHRS.SamplePeriod = 1 / fs;
        
        % -- Correct for WRF alignemnt -- %
        time = linspace(0, length(acc) / fs, length(acc));
        quaternion = zeros(length(time), 4);
        
        for t = 1 : length(time)
            AHRS.UpdateIMU(gyr(t,:), acc(t,:));
            quaternion(t, :) = AHRS.Quaternion;
        end
        
        quaternion_star = quaternConj(quaternion);
        a_q = [zeros(length(acc),1), acc];
        a_temp = quaternProd(quaternion, a_q);
        a_glob = quaternProd(a_temp, quaternion_star);
        offset = mean(a_glob(1:fs,3));
        a_glob = a_glob(:,3) - offset;
        
end