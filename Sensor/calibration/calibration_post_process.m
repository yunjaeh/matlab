clear;
clc;

% data_temp = readtable('./CR300_1_calibration.dat');
V_in = 5000;
R_ref = 220;

data_temp = readtable('./CR300_1_calibration_filtered.dat');
CR300_1.time = datetime(data_temp.Var1);
CR300_1.V = table2array(data_temp(:,3:8));
CR300_1.R = (V_in - CR300_1.V)./CR300_1.V*R_ref ;
CR300_1.T = table2array(data_temp(:,9:14));

T_in = [10:5:45, 40:-5:10, 15:5:45, 40:-5:10];
CR300_1.T_out_mean = zeros(length(T_in),6);
CR300_1.T_out_std = zeros(length(T_in),6);
CR300_1.R_mean = zeros(length(T_in),6);
CR300_1.R_std = zeros(length(T_in),6);

t = 1:length(CR300_1.time);

CR300_1.idx = [594, 951, 1532, 1868, 2221, 2734, 3092, 3560, 4005, 4515, 4961, 5378, 5790, 6161,...
    6580, 6960, 7540, 7903, 8324, 8749, 8946, 9381, 9786. 10160, 10570, 11030, 11430, 11810, 12240 ];


figure();   hold on
plot(t, CR300_1.T(:,1),'b','linewidth',0.5);

for i=1:length(CR300_1.idx)
    idx_temp = (CR300_1.idx(i)-60):CR300_1.idx(i);
    CR300_1.T_out_mean(i,:) = mean(CR300_1.T(idx_temp,:));
    CR300_1.T_out_std(i,:) = std(CR300_1.T(idx_temp,:));
    
    CR300_1.R_mean(i,:) = mean(CR300_1.R(idx_temp,:));
    CR300_1.R_std(i,:) = std(CR300_1.R(idx_temp,:));
    
    plot(t(idx_temp), CR300_1.T(idx_temp,1),'k','linewidth',3);
end
xlabel('Time [sec]');
ylabel('Temperature [C]');


% plot coefficients
%%
% 1/T = a + b ln(R) + c ln^3(R)

p0 = [1.468e-3, 2.383e-4, 1.007e-7];
ft = fittype('a+b*log(x)+c*log(x).^3');
RR = 500:5000;
CR300_1.coef = zeros(6,3);
CR300_1.T_calibrated = zeros(length(T_in),6);

for i=1:6
    p = fit(CR300_1.R_mean(:,i), 1./(T_in+273.15)', ft, 'Start', p0, 'lower',[0 0 0]);
    p.a, p.b, p.c
    CR300_1.coef(i,:) = [p.a, p.b, p.c];
    
    figure(10);     
    subplot(2,3,i);     
    hold on
    plot(1./(p0(1) + p0(2)*log(RR) + p0(3)*log(RR).^3)-273.15, RR ,'k:');
    plot(1./(p.a + p.b*log(RR) + p.c*log(RR).^3)-273.15, RR ,'k');
    plot(T_in, CR300_1.R_mean, 'bo');
    legend('Given fit','New fit','Data points');
    xlabel('Temperature [C]');
    ylabel('Resistance [\Omega]');
    title(['Thermistor',num2str(i)]);
    hold off

    
    figure(11);     
    subplot(2,3,i);     
    hold on
    CR300_1.T_calibrated(:,i) = 1./(p.a + p.b*log(CR300_1.R_mean(:,i)) + p.c*log(CR300_1.R_mean(:,i)).^3)-273.15;
    plot(T_in, CR300_1.T_out_mean(:,i),'bo');
    plot(T_in, CR300_1.T_calibrated(:,i),'bx');
    plot(0:50,0:50,'k--');
    xlabel('Reference Temperature [C]');
    ylabel('Output Temperature [C]');
    title(['Thermistor',num2str(i)]);
    hold off

end








%%
T_idx = [132,380,860, 1159, 1412, 1750, 2236, 2534, 2839, 3148];
T_in = [10, 15, 20, 30, 40, 50, 40, 30, 20, 10];
T_out_mean = zeros(length(T_in),6);
T_out_std = zeros(length(T_in),6);


t = 1:length(data.time);
% figure();   hold on
% for i=1:6
% %     plot(t,data.temp(:,i));
%     plot(data.time,data.temp(:,i));
% end
% xlabel('Time');
% ylabel('Temperature [C]');


figure();   hold on
plot(t, data.temp(:,1),'b','linewidth',0.5);
for i=1:length(T_idx)
    idx_temp = (T_idx(i)-60):T_idx(i);
    T_out_mean(i,:) = mean(data.temp(idx_temp,:));
    T_out_std(i,:) = std(data.temp(idx_temp,:));
    plot(t(idx_temp), data.temp(idx_temp,1),'k','linewidth',3);
end
xlabel('Time [sec]');
ylabel('Temperature [C]');

figure();
hold on
for i=1:6
    plot(T_in, T_out_mean(:,i),'o-');
end
xlabel('Input Temperature [C]');
ylabel('Output Temperature [C]');
legend('Thermistor 1', 'Thermistor 2', 'Thermistor 3' ,'Thermistor 4' ,'Thermistor 5');
plot(0:60, 0:60 ,'k:');


% figure();
% subplot(1,2,1);
% plot(T_in, T_out_mean(:,i),'o-');
% subplot(1,2,2);
% plot(T_in, T_out_mean(:,i)'-T_in,'o-');