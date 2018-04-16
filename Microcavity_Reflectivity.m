function Microcavity_Reflectivity(app)
%Reflectivity vs wavelength of microcavity
%% Initialization of various parameters
paraM=getdataM(app); % getting the parameters from GUI
LambdaCtheta=paraM.LambdaC*sqrt(1-paraM.ni^2*(sin(paraM.thetai))^2/paraM.nc^2);
%LambdaCtheta=app.M_LambdaC.Value*sqrt(1-app.M_ni.Value^2*(sin(app.M_thetai.Value*pi/180))^2/app.M_nc.Value^2);
DeltaLambda=400; % Observed range of wavelength around central wavelength
%%%
%% defining structure for Microcavity
MicrocavityS=DS_Stack(paraM);
%%%
%% find resonance wavelength
%clc;
%[LambdaCRs,LambdaCRp]=Lambda_Resonance(MicrocavityS,LambdaCtheta)
Lambda = paraM.LambdaC-DeltaLambda/2:0.5:LambdaCtheta; % Array of wavelength points for entire range
Lambda=[Lambda,LambdaCtheta:0.004:LambdaCtheta+25];
Lambda=[Lambda,LambdaCtheta+25:0.5:paraM.LambdaC+DeltaLambda/2];
nLambda=numel(Lambda);
%% Calculation of Reflectivity
[Rs,Rp]=Reflectivity_calc(MicrocavityS,Lambda,nLambda);
%%%
%% Plotting Result
cla(app.graph_MCavity);
hold(app.graph_MCavity);
title(app.graph_MCavity,'Reflectivity vs Wavelength of a Microcavity');
xlabel(app.graph_MCavity,'Wavelength (nm)','fontweight','bold');
ylabel(app.graph_MCavity,'Reflectance','fontweight','bold');
plot(app.graph_MCavity,Lambda,Rs,'b-');
plot(app.graph_MCavity,Lambda,Rp,'r-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization' );
hold(app.graph_MCavity);
%clc;
%set(graph1,'LineWidth',1);
%%%
end

