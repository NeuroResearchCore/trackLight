function R = QRSDetectWNECG(ECG, fs, opt)
if nargin < 3
    opt = 1
end;

minECG = prctile(ECG, 20);maxECG = prctile(ECG, 80);
k = (0.5-(-0.5))/(maxECG - minECG); b = -0.5 - k * minECG;
ECG = ECG * k + b;
H2 = qrsdetect(ECG(:), fix(fs+0.5), opt);
idx = find(H2.EVENT.TYP == hex2dec('0501'));
R = H2.EVENT.POS;
%[R] = correctQRS(R, ECG);