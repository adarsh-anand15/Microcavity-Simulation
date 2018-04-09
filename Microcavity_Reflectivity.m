function Microcavity_Reflectivity( )
%Reflectivity vs wavelength of microcavity%
%% Initialization of various parameters
clear;
thetai=30*pi/180; %angle of incidence
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
%%%
%% calculation of various parameters
d1=LambdaC/(4*n1); % Thickness of layer 1
d2=LambdaC/(4*n2); % Thickness of layer 2
dc=LambdaC/(2*nc); % Thickness of cavity layer
Lambda = LambdaC-DeltaLambda/2:DeltaLambda/nLambda:LambdaC+DeltaLambda/2; % Array of wavelength points for entire range
%theta1 = asin(ni/n1*sin(thetai)); % angle of propagation in the medium "1"
%theta2 = asin(ni/n2*sin(thetai)); % angle of propagation in the medium "2"
thetac = asin(ni/nc*sin(thetai)); % angle of propagation in the cavity
thetaf=asin(ni/nf*sin(thetai)); % exit angle 
%%%
%gggs
%% defining structure for Microcavity
n=zeros(1,N_1+N_2+3);
d=zeros(1,N_1+N_2+3);
theta=zeros(1,N_1+N_2+3);
% initial medium
n(1)=ni;
d(1)=0;
theta(1)=thetai;
%%%
% DBR1
for m = 2:N_1+1
    if rem(m,2)==0
        n(m)=n1; % may introduce disorder later
        d(m)=d1; % may introduce disorder later
    else
        n(m)=n2;
        d(m)=d2;
    end   
    theta(m)=asin(ni/n(m)*sin(thetai));
end
%%%
% cavity layer
n(N_1+2)=nc;
d(N_1+2)=dc;
theta(N_1+2)=thetac;
% DBR2
for m = N_1+3:N_1+N_2+2
    if rem(m,2)==0
        n(m)=n1; % may introduce disorder later
        d(m)=d1; % may introduce disorder later
    else
        n(m)=n2;
        d(m)=d2;
    end   
    theta(m)=asin(ni/n(m)*sin(thetai));
end
% final layer
n(N_1+N_2+3)=nf;
d(N_1+N_2+3)=0;
theta(N_1+N_2+3)=thetaf;
%%%
%% Finding Characteristic matrices
% initializing as identity matrix
for z=1:nLambda+1;
        Ss(:,:,z)=eye(2);
        Sp(:,:,z)=eye(2);
end
%%%
% for each layer
for m=1:N_1+N_2+2
    deltam=((2*pi./Lambda)*n(m)*d(m)*cos(theta(m)));
    % for s polarization
    rms=((n(m)*cos(theta(m)))-(n(m+1)*cos(theta(m+1))))/((n(m)*cos(theta(m)))+(n(m+1)*cos(theta(m+1))));
    tms=(2*n(m)*cos(theta(m)))/(n(m)*cos(theta(m)+n(m+1)*cos(theta(m+1))));
    Sms(1,1,:)=(1/tms)*exp(1i*deltam);
    Sms(1,2,:)=(rms/tms)*exp(1i*deltam);
    Sms(2,1,:)=(rms/tms)*exp(-1i*deltam);
    Sms(2,2,:)=(1/tms)*exp(-1i*deltam);
    % for p polarization
    rmp=((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))-(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))))/((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))+(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))));
    tmp=(2*n(m)*n(m)*sin(theta(m))*cos(theta(m)))/((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))+(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))));
    Smp(1,1,:)=(1/tmp)*exp(1i*deltam);
    Smp(1,2,:)=(rmp/tmp)*exp(1i*deltam);
    Smp(2,1,:)=(rmp/tmp)*exp(-1i*deltam);
    Smp(2,2,:)=(1/tmp)*exp(-1i*deltam);
    for z=1:nLambda+1
        Ss(:,:,z)=Ss(:,:,z)*Sms(:,:,z);
        Sp(:,:,z)=Sp(:,:,z)*Smp(:,:,z);
    end
end
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
hold on
xlabel('Wavelength (nm)','fontweight','bold');
ylabel('Reflectance','fontweight','bold');
graphs=plot(Lambda,Rs(:),'b-');
graphp=plot(Lambda,Rp(:),'r-');
%set(graph1,'LineWidth',1);
%%%
end

