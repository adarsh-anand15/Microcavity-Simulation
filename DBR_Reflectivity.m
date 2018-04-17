function DBR_Reflectivity(app)
%% Initialization of various parameters
paraD=getdataD(app); % getting the parameters from GUI
DeltaLambda=400; % Observed range of wavelength around central wavelength
Lambda=paraD.LambdaC-DeltaLambda/2:0.5:paraD.LambdaC+DeltaLambda/2;
nLambda=numel(Lambda);
%% defining structure for Microcavity
DBRS=DS_DBR(paraD);
%% Calculation of Reflectivity
[Rs,Rp,R]=Reflectivity_calc(DBRS,Lambda,nLambda,paraD.thetaEi);
%% Plotting Result
clc;
cla(app.graph_DBR);
hold(app.graph_DBR,'on');
ylim(app.graph_DBR,'auto');
title(app.graph_DBR,'Reflectivity vs Wavelength of a DBR');
xlabel(app.graph_DBR,'Wavelength (nm)','fontweight','bold');
ylabel(app.graph_DBR,'Reflectivity','fontweight','bold');
plot(app.graph_DBR,Lambda,Rs,'b-');
plot(app.graph_DBR,Lambda,Rp,'r-');
plot(app.graph_DBR,Lambda,R,'g-');
legend(app.graph_DBR,'s-Polarization','p-Polarization','Total' );
hold(app.graph_DBR,'off');
end