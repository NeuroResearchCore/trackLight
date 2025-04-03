function [derivative1,derivative2] = derivative2(Predicted_y)
Predicted_y_rightshift = [Predicted_y(1) Predicted_y(1:length(Predicted_y)-1)];
derivative1 = Predicted_y - Predicted_y_rightshift;
derivative1_rightshift = [derivative1(1) derivative1(1:length(Predicted_y)-1)];
derivative2 = derivative1-derivative1_rightshift;
derivative1(1)= 1;


