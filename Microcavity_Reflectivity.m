function Microcavity_Reflectivity(app)
%Reflectivity vs wavelength of microcavity
%% Initialization of various parameters
paraM=getdataM(app); % getting the parameters from GUI
LambdaCtheta=paraM.LambdaC*sqrt(1-paraM.ni^2*(sin(paraM.thetai))^2/paraM.nc^2);
%LambdaCtheta=app.M_LambdaC.Value*sqrt(1-app.M_ni.Value^2*(sin(app.M_thetai.Value*pi/180))^2/app.M_nc.Value^2);
DeltaLambda=300; % Observed range of wavelength around central wavelength
%% defining structure for Microcavity
MicrocavityS=DS_Microcavity(paraM);
%% find resonance wavelength
%clc;
%[LambdaCRs,LambdaCRp]=Lambda_Resonance(MicrocavityS,LambdaCtheta)
%% Array of wavelength points for entire range
Lambda = paraM.LambdaC-DeltaLambda/2:0.5:LambdaCtheta; 
Lambda=[Lambda,LambdaCtheta:0.004:LambdaCtheta+25];
Lambda=[Lambda,LambdaCtheta+25:0.5:paraM.LambdaC+DeltaLambda/2];
nLambda=numel(Lambda);
%% Calculation of Reflectivity
[Rs,Rp,R]=Reflectivity_calc(MicrocavityS,Lambda,nLambda,paraM.thetaEi);
%% Plotting Result
clc;
cla(app.graph_MCavity);
hold(app.graph_MCavity,'on');
ylim(app.graph_MCavity,'auto');
title(app.graph_MCavity,'Reflectivity vs Wavelength of a Microcavity');
xlabel(app.graph_MCavity,'Wavelength (nm)','fontweight','bold');
ylabel(app.graph_MCavity,'Reflectivity','fontweight','bold');
plot(app.graph_MCavity,Lambda,Rs,'b-');
plot(app.graph_MCavity,Lambda,Rp,'r-');
plot(app.graph_MCavity,Lambda,R,'g-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization','Given Polarization' );
hold(app.graph_MCavity,'off');
%%
%{
hold('on');
ylim('auto');
title('Reflectivity vs Wavelength of a Microcavity');
xlabel('Wavelength (nm)','fontweight','bold');
ylabel('Reflectivity','fontweight','bold');
subplot(1,3,1) ;
plot(Lambda,Rs,'b-');
subplot(1,3,1); 
plot(Lambda,Rp,'r-');
subplot(1,3,1) ;
plot(Lambda,R,'g-');
legend('s-Polarization','p-Polarization','Given Polarization' );
hold('off');
%}
end