%Kalman filter for ICP peak detection correction
%function input:different peak detection algorithms' estimation error v:from
%training data(idxtrain)
%Kalman filter input:the last prediction from algorithm
%Output:ye
%function ye = KalmanTracking(Yhat,Y,idxtest,idxtrain)
% every n times add real-time correction
function [ye] = KalmanTracking3(Yhat, Y,idxTrain, idxTest)
n = length(Y(idxTest));
t = 1:1:n;
meanYTrain = mean(Y(idxTrain));
stdYTrain = std(Y(idxTrain));
Ynormalized = (Y(idxTest)-mean(Y(idxTest)))/std(Y(idxTest));
YhatNormalized = (Yhat-mean(Yhat))/std(Yhat);

% Ynormalized = Y(idxTest);
% YhatNormalized = Yhat;
y = Ynormalized;
u = [YhatNormalized(1:end-1);0];%[dataLearnTst.Y(idxTest(1:end-1),1); 0];%true former response as one input of Kalman filter,
 
%  u = zeros(1,n);%repmat(yMean,n,1);
%  w = (Y(idxTest)-yMean)/yStd;
 
yv = YhatNormalized;%%%y+v;
v = YhatNormalized- Ynormalized;%Yhat -dataLearnTst.Y(idxTest,1); %Y

noise = randn(n,1);
noise = noise/max(noise);
%  v = sqrt(R)*noise;
%  w = sqrt(Q)*noise;
R = mean(v.*v);
 Q =0.9; %0.8 mean(w.*w);%0.1-1;0.05-0.5;1000-100(ye·¶Î§)
w = sqrt(Q)*noise;

N = mean(w.*v);
A = [1.1269   -0.4940    0.1129;
 1.0000         0         0;
      0    1.0000         0];
B = [-0.3832;
      0.5919;
      0.5191];
% A =zeros(3,3);
% 
% B = [1;
%      1;
%      1];

C = [1 0 0];

% sys = ss(A,B,C,0,-1);
%  y = lsim(sys,u+w);    
%  yv=y + v;
P = B*Q*B';         % Initial error covariance
x = zeros(3,1);     % Initial condition on the state
ye = zeros(length(t),1);
ycov = zeros(length(t),1); 

for i = 1:length(t)
  % Measurement update
  Mn = P*C'/(C*P*C'+R);
  x = x + Mn*(yv(i)-C*x);   % x[n|n]
  P = (eye(3)-Mn*C)*P;      % P[n|n]

  ye(i) = C*x;
  errcov(i) = C*P*C';

  % Time update
  x = A*x + B*u(i);        % x[n+1|n]
  P = A*P*A' + B*Q*B';     % P[n+1|n]
end

ye = ye*std(Yhat)+mean(Yhat);
% ye = ye*stdYTrain+meanYTrain;
yv = yv*std(Yhat)+mean(Yhat);
y  = y*std(Y(idxTest))+mean(Y(idxTest));
% ye = out;

% subplot(211), plot(t,y,'--',t,ye,'-',t,yv,'g'), 
% xlabel('No. of samples'), ylabel('Output')
% title('Kalman filter response')
% subplot(212), plot(t,y-yv,'-.',t,y-ye,'-'),
% xlabel('No. of samples'), ylabel('Error')
% rmse = sqrt(mean((ye-y).^2))       
% stdE = (mean((ye-y).^2) - mean(ye-y).^2) / sqrt(numel(ye-y))
% rmse1 = sqrt(mean((yv-y).^2))       
% stdE1 = (mean((yv-y).^2) - mean(yv-y).^2) / sqrt(numel(yv-y))
% str = ['RMSE= ',num2str(rmse)];
% title(str)
g = 1;