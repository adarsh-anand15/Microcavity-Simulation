function DBR_Exp_vs_Sim(app)
%% getting experimental data
x=xlsread('zone 9 12','1304102U1_01','A7:A2738');
y=xlsread('zone 9 12','1304102U1_01','B7:B2738');
y=y./100;
[ymax,ymaxI]=max(y);
y=y./ymax;
app.D_LambdaC.Value=x(ymaxI);
%% Initialization of various parameters
app.D_thetai.Value=0;
paraD=getdataD(app); % getting the parameters from GUI
DeltaLambda=400; % Observed range of wavelength around central wavelength
Lambda=paraD.LambdaC-DeltaLambda/2:0.5:paraD.LambdaC+DeltaLambda/2;
nLambda=numel(Lambda);
%% defining structure for Microcavity
DBRS=DS_DBR(paraD);
%% Calculation of Reflectivity
[~,~,R]=Reflectivity_calc(DBRS,Lambda,nLambda,paraD.thetaEi);
%% Plotting Result


clc;
cla(app.graph_DBR);
hold(app.graph_DBR,'on');
ylim(app.graph_DBR,'auto');
title(app.graph_DBR,'Reflectivity vs Wavelength of a DBR');
xlabel(app.graph_DBR,'Wavelength (nm)','fontweight','bold');
ylabel(app.graph_DBR,'Reflectivity','fontweight','bold');
plot(app.graph_DBR,x,y,'b-');
%plot(app.graph_DBR,Lambda,Rs,'r-');
%plot(app.graph_DBR,Lambda,Rp,'r-');
plot(app.graph_DBR,Lambda,R,'g-');
legend(app.graph_DBR,'Experiment','Simulation' );
hold(app.graph_DBR,'off');
end