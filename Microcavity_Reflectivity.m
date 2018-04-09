function Microcavity_Reflectivity( )
%Reflectivity vs wavelength of microcavity%
%% Initialization of various parameters
clear;
Eiv=[3,5,4];
Ei=sqrt((Eiv(1))^2+(Eiv(2))^2+(Eiv(3))^2);
thetai=0*pi/180; %angle of incidence
ni=1; % initial medium
nf=1; % final medium
N_1=11; % No. of layers for one DBR1
N_2=11; % No. of layers for one DBR2
n1= 2.02; % Refractive index of medium 1
n2=1.46; %Refractive index of medium 2
nc= n2; % Refractive index of medium of cavity
LambdaC=530; % central wavelength
DeltaLambda=400; % Observed range of wavelength around central wavelength
nLambda=1000; % No. of points in graph
Lambda = LambdaC-DeltaLambda/2:DeltaLambda/nLambda:LambdaC+DeltaLambda/2; % Array of wavelength points for entire range
if thetai~=0
    Esi=Eiv(2);
    Epi=sqrt((Eiv(1))^2+(Eiv(3))^2);
else
    Esi=Ei;
    Epi=Ei;
Esr=zeros(1,nLambda+1);
Epr=zeros(1,nLambda+1);
Er=zeros(1,nLambda+1);
%%%
%% defining structure for Microcavity
[n,d,theta]=DSM(N_1,N_2,ni,nf,n1,n2,nc,thetai,LambdaC);
%%%
%% Finding Characteristic matrices
[ Ss,Sp ] = CM( N_1+N_2+1,n,d,theta,Lambda,nLambda );
%%%
%% Reflectivity calculation
rs=zeros(1,nLambda+1);
rp=zeros(1,nLambda+1);
r=zeros(1,nLambda+1);
for z=1:nLambda+1
    rs(z)=Ss(2,1,z)/Ss(1,1,z);
    rp(z)=Sp(2,1,z)/Sp(1,1,z);
    Esr(z)=Esi*rs(z);
    Epr(z)=Epi*rp(z);
    Er(z)=sqrt((Esr(z))^2+(Epr(z))^2);
    r(z)=Er(z)/Ei;
end
Rs=zeros(1,nLambda+1);
Rp=zeros(1,nLambda+1);
R=zeros(1,nLambda+1);
for z=1:nLambda+1;
    Rs(z)=abs(rs(z))*abs(rs(z));
    Rp(z)=abs(rp(z))*abs(rp(z));
    R(z)=abs(r(z))*abs(r(z));
end
%%%
%% Plotting Result
hold on
xlabel('Wavelength (nm)','fontweight','bold');
ylabel('Reflectance','fontweight','bold');
%plot(Lambda,Rs(:),'b-');
%plot(Lambda,Rp(:),'r-');
plot(Lambda,R(:),'b-');
%set(graph1,'LineWidth',1);
%%%
end

