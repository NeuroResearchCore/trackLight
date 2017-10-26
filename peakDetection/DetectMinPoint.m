function pos = DetectMinPoint(subsig, fs)

warning('off'); %#ok<WNOFF>
wl= fix(8 * fs / 400);

index=0;
%flag=0;
for j=1:wl:length(subsig)
    index=index+1;
    if j+wl-1>length(subsig)
        break;
    end

    Sub_Sig_Array=subsig(j:j+wl-1);
    x_cord=j:j+wl-1;
    coeff = polyfit(x_cord(:), Sub_Sig_Array(:), 2);
    fit_value_array = polyval(coeff, x_cord);
    [min_array(index),tt]=min(fit_value_array);
    min_pos_array(index)=x_cord(tt);
end
if( index > 2)
    Grand_min_value = interp1(min_pos_array(:),min_array(:),[1:length(subsig)]','spline');
    [tt, pos]=min(Grand_min_value(min_pos_array(1):min_pos_array(end)));
    pos = pos + min_pos_array(1) - 1;
else
    [t, pos] = min(subsig);
end;