load('.\ICPdatabase.mat')
figure;
plot(vv{1})
hold on;
plot([l1(1) l2(1) l3(1)],[vv{1}(l1(1)) vv{1}(l2(1)) vv{1}(round(l3(1)))],'ro');
