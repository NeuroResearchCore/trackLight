function pos = DetectMinPointOpt(dv, ~)

[~, maxpos] = max(dv);
[~, pos] = min(dv(1:maxpos));
