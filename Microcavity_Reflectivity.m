function Microcavity_Reflectivity(handles)
%Reflectivity vs wavelength of microcavity%
%% Initialization of various parameters
%clear;
thetai=str2num(get(handles.thetai,'string'))*pi/180;%30*pi/180; %angle of incidence
Ei=str2num(get(handles.Ei,'string'));% Initial Electric field amplitude
thetaEi=str2num(get(handles.thetaEi,'string'));% Angle between Electric field and plane of incidence
ni=str2num(get(handles.ni,'string'));%1; % initial medium
nf=str2num(get(handles.nf,'string'));%1; % final medium
N_1=str2num(get(handles.N_1,'string'));%11; % No. of layers for one DBR1
N_2=str2num(get(handles.N_2,'string'));%11; % No. of layers for one DBR2
n1=str2num(get(handles.n1,'string'));% 2.02; % Refractive index of medium 1
n2=str2num(get(handles.n2,'string'));%1.46; %Refractive index of medium 2
nc= str2num(get(handles.nc,'string'));%n2; % Refractive index of medium of cavity
LambdaC=str2num(get(handles.LambdaC,'string'));%530; % central wavelength
DeltaLambda=400; % Observed range of wavelength around central wavelength
nLambda=1000; % No. of points in graph
Lambda = LambdaC-DeltaLambda/2:DeltaLambda/nLambda:LambdaC+DeltaLambda/2; % Array of wavelength points for entire range
%%%
%% defining structure for Microcavity
[n,d,theta]=DSM(N_1,N_2,ni,nf,n1,n2,nc,thetai,LambdaC);
%%%
%% Finding Characteristic matrices
[ Ss,Sp ] = CM( N_1+N_2+1,n,d,theta,Lambda,nLambda );
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

