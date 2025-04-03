%取温度预测值的方差为Q=1e-3,温度传感器的测量方差为R=0.36，即我们更相信预测值，而较少相信传感器测量值。
function Y_kalman = LinearKalmanTracking5(Yhat, Y,idxTrain, idxTest)
yhat = Yhat;
Q=0.5;
N = size(yhat,1);
r = yhat-Y(idxTest);
R = std(r);
Y_start = mean(Y(idxTest));
P_start = 1;
Y_kalman = Y_start;
P_kalman(1) = P_start;
for k = 2:N
    Y_pre(k)=Y_kalman(k-1);
    P_pre(k)=P_kalman(k-1)+Q;
    K(k)=P_pre(k)/(P_pre(k)+R);
    Y_kalman(k)=Y_pre(k)+K(k)*(yhat(k)-Y_pre(k));
    P_kalman(k)=P_pre(k)-K(k)*P_pre(k);
end


% Q=1e-3;  R=0.36;  T_mearsured=T+sqrt(R)*randn(size);
% %初始时刻温度的最优估计值为T_start=22.5度,温度初始估计方差为P_start=2
% T_start=22.5;  P_start=2;
% T_kalman(1)=T_start;  P_kalman(1)=P_start;
% %用_kalman的后缀表示最优估计值，用_pre的后缀表示预测值
% for k=2:N
% %在进行温度预测时，因为温度是一个连续的状态，我们认为上一时刻的温度和当前时刻的温度相等，则有T(k)=T(k-1)。
% T_pre(k)=T_kalman(k-1);
% P_pre(k)=P_kalman(k-1)+Q;
% K(k)=P_pre(k)/(P_pre(k)+R);
% T_kalman(k)=T_pre(k)+K(k)*(T_mearsured(k)-T_pre(k));
% P_kalman(k)=P_pre(k)-K(k)*P_pre(k);

%画图
% figure;
% plot(Y(idxTest),'g');
% hold on
% plot(yhat,'b');
% hold on
% plot(Y_kalman,'r');
% legend('real','detected','Kalman estmiation')
end
