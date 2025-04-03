function osig = zpIIR(sig,p,rp,rs,wn,blowpass)
%estimate the time constants

%if nargin < 6
%    blowpass = 1;
%end;

if(blowpass)
    [b,a] = ellip(p,rp,rs,wn);
else
    [b,a] = ellip(p,rp,rs,wn,'high');
end;

osig = filtfilt(b, a, double(sig));
