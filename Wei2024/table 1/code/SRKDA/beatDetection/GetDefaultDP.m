function  dp = GetDefaultDP(rr, severeConstriction, fs )
if (nargin < 2)
    severeConstriction = 0;
    fs = 400;
elseif nargin < 3
    fs = 400;
end;

if (severeConstriction == 0)
    dp.gap00 =  150 * fs/ 1000;
else
    dp.gap00 =  50 * fs/ 1000;
end;


dp.gap01 =  800 * fs / 1000;
dp.gap10 =  rr*0.8 *fs/1000;
dp.gap11 =  rr*1.5*fs/1000;

if (severeConstriction == 0)
    dp.w00 =  100 * fs /1000;
else
    dp.w00 =  200 * fs /1000;
end;
dp.w01 =  150 *fs/1000;
dp.w11  = 250*fs / 1000;
dp.w12 =  250*fs/1000;

dp.k1 = 0.01;
dp.k2 = 0.01;
dp.k3 = 0.01;
dp.k4 = 0.01;