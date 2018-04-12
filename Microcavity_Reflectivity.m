function Microcavity_Reflectivity(handles)
%Reflectivity vs wavelength of microcavity%
%% Initialization of various parameters
%clear;
parameters=getdata(handles); % getting the parameters from GUI
DeltaLambda=400; % Observed range of wavelength around central wavelength
nLambda=1000; % No. of points in graph
Lambda = parameters.LambdaC-DeltaLambda/2:DeltaLambda/nLambda:parameters.LambdaC+DeltaLambda/2; % Array of wavelength points for entire range
%%%
%% defining structure for Microcavity
MicrocavityS=DSMicrocavity(parameters);
%%%
%% Finding Characteristic matrices
[ Ss,Sp ] = CMatrices(MicrocavityS,Lambda,nLambda );
%%%
%% Reflectivity calculation
for z=1:nLambda+1
    rs(z)=Ss(2,1,z)/Ss(1,1,z);
    rp(z)=Sp(2,1,z)/Sp(1,1,z);
end
for z=1:nLambda+1;
    Rs(z)=abs(rs(z))*abs(rs(z));
    Rp(z)=abs(rp(z))*abs(rp(z));
end
%%%
%% Plotting Result
cla(handles.graph);
hold on
xlabel('Wavelength (nm)','fontweight','bold');
ylabel('Reflectance','fontweight','bold');
plot(Lambda,Rs(:),'b-');
plot(Lambda,Rp(:),'r-');
%set(graph1,'LineWidth',1);
%%%
end

