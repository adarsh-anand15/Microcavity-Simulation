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
DeltaLambda=400; % Observed range of wavelength around central wavelength
nLambda=1000; % No. of points in graph
Lambda = app.M_LambdaC.Value-DeltaLambda/2:DeltaLambda/nLambda:app.M_LambdaC.Value+DeltaLambda/2; % Array of wavelength points for entire range
%%%
%% defining structure for Microcavity
MicrocavityS=DSMicrocavity(app);
%%%
%% Finding Characteristic matrices
[ Ss,Sp ] = CMatrices(MicrocavityS,Lambda,nLambda );
%%%
%% Reflectivity calculation
% Initializing with zeros
rs=zeros(1,nLambda+1);
rp=zeros(1,nLambda+1);
Rs=zeros(1,nLambda+1);
Rp=zeros(1,nLambda+1);
for z=1:nLambda+1
    rs(z)=Ss(2,1,z)/Ss(1,1,z);
    rp(z)=Sp(2,1,z)/Sp(1,1,z);
end
for z=1:nLambda+1
    Rs(z)=abs(rs(z))*abs(rs(z));
    Rp(z)=abs(rp(z))*abs(rp(z));
end
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
clc;
%set(graph1,'LineWidth',1);
%%%
end

