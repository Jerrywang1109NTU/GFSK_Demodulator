fixed_10_point = [0.00313670682562117	0.00144295584765757	0.000372341820279519	0.000139990667288847];
fixed_12_point = [0.00212354006620448	0.000747077454044214	0.000270093389983691	4.71349788678178e-05];
fixed_14_point = [0.00196453416569830	0.000670300492073307	0.000177163610594384	4.74110910345627e-05];
fixed_16_point = [0.00192729831637101	0.000799877913371117	0.000192220773350928	5.21232401891031e-05];
float_point    = [5.53066755157348e-05	9.90635367455334e-06	2.09154045091521e-06	0];
semilogy(fixed_10_point, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);
hold on;
semilogy(fixed_12_point, 'g-s', 'LineWidth', 2, 'MarkerSize', 6);
semilogy(fixed_14_point, 'b-x', 'LineWidth', 2, 'MarkerSize', 6);
semilogy(fixed_16_point, 'k-^', 'LineWidth', 2, 'MarkerSize', 6);
semilogy(float_point, 'm-p', 'LineWidth', 2, 'MarkerSize', 6);
title('BER of diffferent fix point method');
xlabel('EbN0 (dB)');   ylabel('BER');
legend('fixed-10-point', 'fixed-12-point', 'fixed-14-point', 'fixed-16-point', 'float-point')
