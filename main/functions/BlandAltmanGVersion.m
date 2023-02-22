function BlandAltmanGVersion(y1, y2, modelName)
% BLANDALTMAN is a function to plot Bland Altman plots following Giavarina
% [2015] applications.
%Input variables:   - y1: values of output.
%                   - y2: values coming from the model.
%                   - modelName: name of the model.
%% Main computation
x = zeros(length(y1),1);
y = x;

for i = 1 : length(y1)
    x(i,1) = (y1(i) + y2(i)) / 2;
    y(i,1) = (y1(i) - y2(i));
end

d = mean(y)
sd = std(y)

LB = d - 1.96 * sd
UB = d + 1.96 * sd

tbl = table(y,x);
mdl = fitlm(tbl,'y ~ x')

intercept=round(mdl.Coefficients.Estimate(1),2);
coeff=round(mdl.Coefficients.Estimate(2),2);
label1= convertStringsToChars("y-y_______ = "+intercept+"+"+coeff+"*(y+y_____)/2");
label2= convertStringsToChars("R^2 = "+round(mdl.Rsquared.Ordinary,2));
%% Plot
figure
hold on
%confidence intervals
t_value=2.0032;
se=sqrt(sd^2/57);
selim=sqrt(3*sd^2/57);
%BIAS
yline(d-(t_value*se), 'Linewidth', 1.5, 'Color', [0 0 0],'LineStyle', '-.')
yline(d+(t_value*se), 'Linewidth', 1.5, 'Color', [0 0 0],'LineStyle', '-.')
yline(UB-(t_value*selim), 'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-.')
yline(UB+(t_value*selim), 'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-.')
yline(LB-(t_value*selim), 'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-.')
yline(LB+(t_value*selim), 'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-.')
fill([1.25 2.35 2.35 1.25],[-0.6 -0.6 0.6 0.6], [1 1 1],'EdgeColor','k')
fill([1.2515 2.3485 2.3485 1.2515],[d-(t_value*se) d-(t_value*se) d+(t_value*se) d+(t_value*se)], [0.94 0.94 0.94], 'EdgeColor',[0.94 0.94 0.94])
fill([1.2515 2.3485 2.3485 1.2515],[UB-(t_value*selim) UB-(t_value*selim) UB+(t_value*selim) UB+(t_value*selim)], [0.94 0.94 0.94],'EdgeColor',[0.94 0.94 0.94])
fill([1.2515 2.3485 2.3485 1.2515],[LB-(t_value*selim) LB-(t_value*selim) LB+(t_value*selim) LB+(t_value*selim)], [0.94 0.94 0.94],'EdgeColor',[0.94 0.94 0.94])
plot(x,y, 'o', 'MarkerFaceColor','k','MarkerSize',8,'Color','k');
xlim([1.25 2.35])
ylim([-0.6 0.6])
fontname(gca,"Palatino Linotype")
fontsize(gca,26,"points")
hold on
xplot= 1.25:0.01:2.35;
plot(xplot,intercept+coeff*xplot,'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-')
text(1.6,0.50,label1,"FontSize",28,FontWeight="normal",FontName='Palatino Linotype',VerticalAlignment='baseline',HorizontalAlignment='center')
text(2.2,0.50,label2, "FontSize",28,FontWeight="normal",FontName='Palatino Linotype',VerticalAlignment='baseline',HorizontalAlignment='center')
yline(d, 'Linewidth', 2, 'Color', [0 0 0],'LineStyle', '-','Label','BIAS',FontName='Palatino Linotype',FontSize=28, FontWeight='normal')
yline(UB, 'Linewidth', 2, 'Color', [0 0 0], 'LineStyle', '--','Label','UL',FontName='Palatino Linotype',FontSize=28, FontWeight='normal')
yline(LB, 'Linewidth', 2, 'Color', [0 0 0], 'LineStyle', '--','Label','LL',FontName='Palatino Linotype',FontSize=28, FontWeight='normal')
%title
title("() "+modelName+ " Model", FontSize=30, FontName='Palatino Linotype', FontWeight='normal')
xlabel('Mean(y, y______) [m]', 'FontSize',28, 'FontName','Palatino Linotype', FontWeight='normal')
ylabel('y - y_________ [m]', 'FontSize',28, 'FontName','Palatino Linotype', FontWeight='normal')

xLB = min(x) + .5*min(x);
xUB = max(x) + .5*max(x);
d-(t_value*se)
d+(t_value*se)
UB-(t_value*selim)
UB+(t_value*selim)
LB-(t_value*selim)
LB+(t_value*selim)
t_value
se
selim
end

