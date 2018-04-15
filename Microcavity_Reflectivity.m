function Microcavity_Reflectivity(app)
%Reflectivity vs wavelength of microcavity%
%% Initialization of various parameters
%clear;
%parametersM=getdataM(app); % getting the parameters from GUI
app.M_D1_d1.Value=app.M_LambdaC.Value/(4*app.M_D1_n1.Value); % Thickness of layer 1 of DBR1
app.M_D1_d2.Value=app.M_LambdaC.Value/(4*app.M_D1_n2.Value); % Thickness of layer 2 of DBR1
app.M_D2_d1.Value=app.M_LambdaC.Value/(4*app.M_D2_n1.Value); % Thickness of layer 1 of DBR2
app.M_D2_d2.Value=app.M_LambdaC.Value/(4*app.M_D2_n2.Value); % Thickness of layer 2 of DBR2
app.M_dc.Value=app.M_LambdaC.Value/(2*app.M_nc.Value); % Thickness of cavity layer
LambdaCtheta=app.M_LambdaC.Value*sqrt(1-app.M_ni.Value^2*(sin(app.M_thetai.Value*pi/180))^2/app.M_nc.Value^2);
DeltaLambda=400; % Observed range of wavelength around central wavelength
%%%
%% defining structure for Microcavity
MicrocavityS=DSMicrocavity(app);
%%%
%% find resonance wavelength
%[~,LambdaCRp]=Lambda_Resonance(MicrocavityS,LambdaCtheta);
Lambda = app.M_LambdaC.Value-DeltaLambda/2:0.5:LambdaCtheta; % Array of wavelength points for entire range
Lambda=[Lambda,LambdaCtheta:0.004:LambdaCtheta+25];
Lambda=[Lambda,LambdaCtheta+25:0.5:app.M_LambdaC.Value+DeltaLambda/2];
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
plot(app.graph_MCavity,Lambda,Rp,'r-');
plot(app.graph_MCavity,Lambda,Rs,'b-');
hold(app.graph_MCavity);
%clc;
%set(graph1,'LineWidth',1);
%%%
end

