function field_profile(handles)
%Field Profile of Microcavity%
%% Initialization of various parameters
%clear
thetai=0; %angle of incidence
%thetai=str2num(get(handles.thetai,'string'))*pi/180;%30*pi/180; %angle of incidence
Ei=str2num(get(handles.Ei,'string'));% Initial Electric field amplitude
%thetaEi=str2num(get(handles.thetaEi,'string'));% Angle between Electric field and plane of incidence
ni=str2num(get(handles.ni,'string'));%1; % initial medium
nf=str2num(get(handles.nf,'string'));%1; % final medium
%N_1=str2num(get(handles.N_1,'string'));%11; % No. of layers for one DBR1
%N_2=str2num(get(handles.N_2,'string'));%11; % No. of layers for one DBR2
n1=str2num(get(handles.n1,'string'));% 2.02; % Refractive index of medium 1
n2=str2num(get(handles.n2,'string'));%1.46; %Refractive index of medium 2
nc= str2num(get(handles.nc,'string'));%n2; % Refractive index of medium of cavity
LambdaC=str2num(get(handles.LambdaC,'string'));%530; % central wavelength
%ni=1; % initial medium
%nf=1; % final medium
N=43; % No. of layers for one DBR
%n1= 2.02; % Refractive index of medium 1
%n2=1.46; %Refractive index of medium 2
%nc= n2; % Refractive index of medium of cavity
%LambdaC=530; % central wavelength
%Ei=5; %Initial electric field amplitude in V/m
%%%
%% calculation of various parameters
d1=LambdaC/(4*n1); % Thickness of layer 1
d2=LambdaC/(4*n2); % Thickness of layer 2
dc=LambdaC/(2*nc); % Thickness of cavity layer
theta1 = asin(ni/n1*sin(thetai)); % angle of propagation in the medium "1"
theta2 = asin(ni/n2*sin(thetai)); % angle of propagation in the medium "2"
thetac = asin(ni/nc*sin(thetai)); % angle of propagation in the cavity
thetaf=asin(ni/nf*sin(thetai)); % exit angle 
%%%
%% defining structure
    for k = 1:N
        if rem(k,2)==0
            n(k)=n2;
            d(k)=d2;
            theta(k)=theta2;
        else
            n(k)=n1;
            d(k)=d1;
            theta(k)=theta1;
        end    
    end
%%%
%% Finding Characteristic matrices
S=eye(2); % Initializing as identity matrix
% interface of initial medium and first layer of first DBR
ti=(2*ni)/(ni+n(1));
ri=(ni-n(1))/(ni+n(1));
Si(1,1)=1/ti;
Si(1,2)=ri/ti;
Si(2,1)=ri/ti;
Si(2,2)=1/ti;
S=S*Si;
%%%
% mid layers for first DBR
for k= 1:N-1
    tk=(2*n(k))/(n(k)+n(k+1));
    rk=(n(k)-n(k+1))/(n(k)+n(k+1));
    deltak=((2*pi/LambdaC)*n(k)*d(k));
    Sk(1,1)=(1/tk)*exp(i*deltak);
    Sk(1,2)=(rk/tk)*exp(i*deltak);
    Sk(2,1)=(rk/tk)*exp(-i*deltak);
    Sk(2,2)=(1/tk)*exp(-i*deltak);
    S=S*Sk;
end
%%%
% interface with cavity and final layer of first DBR
tfc=(2*n(N))/(n(N)+nc);
rfc=(n(N)-nc)/(n(N)+nc);
deltaN1=((2*pi/LambdaC)*n(N)*d(N));
Sfc(1,1)=(1/tfc)*exp(i*deltaN1);
Sfc(1,2)=(rfc/tfc)*exp(i*deltaN1);
Sfc(2,1)=(rfc/tfc)*exp(-i*deltaN1);
Sfc(2,2)=(1/tfc)*exp(-i*deltaN1);
S=S*Sfc;
%%%
% interface with cavity and first layer of second DBR
tc=(2*nc)/(nc+n(1));
rc=(nc-n(1))/(nc+n(1));
deltaC=((2*pi/LambdaC)*nc*dc);
Sc(1,1)=(1/tc)*exp(i*deltaC);
Sc(1,2)=(rc/tc)*exp(i*deltaC);
Sc(2,1)=(rc/tc)*exp(-i*deltaC);
Sc(2,2)=(1/tc)*exp(-i*deltaC);
S=S*Sc;
%%%   
% mid layers of second DBR
for k= 1:N-1
    tk=(2*n(k))/(n(k)+n(k+1));
    rk=(n(k)-n(k+1))/(n(k)+n(k+1));
    deltak=((2*pi/LambdaC)*n(k)*d(k));
    Sk(1,1)=(1/tk)*exp(i*deltak);
    Sk(1,2)=(rk/tk)*exp(i*deltak);
    Sk(2,1)=(rk/tk)*exp(-i*deltak);
    Sk(2,2)=(1/tk)*exp(-i*deltak);
    S=S*Sk;
end
%%%
% interface of final layer of second DBR and final medium    
tf=(2*n(N))/(n(N)+nf);
rf=(n(N)-nf)/(n(N)+nf);
deltaN=((2*pi/LambdaC)*n(N)*d(N));
Sf(1,1)=(1/tf)*exp(i*deltaN);
Sf(1,2)=(rf/tf)*exp(i*deltaN);
Sf(2,1)=(rf/tf)*exp(-i*deltaN);
Sf(2,2)=(1/tf)*exp(-i*deltaN);
S=S*Sf;
%%%
%% Calculation of Ebi
r=S(2,1)/S(1,1); % Amplitude reflection coefficient
Ei=[Ei;r*Ei];
%%%
%% Collecting points to plot
% initial medium
xi=-LambdaC:LambdaC/4000:0;
kp=2*pi/LambdaC*ni;
yi=real(Ei(1)*exp(-i*kp*xi)+Ei(2)*exp(i*kp*xi));
x=xi;
y=yi;
%%%
% first layer of first DBR
l=0;
xk=l:d(1)/1000:d(1)+l;
l=l+d(1);
kp=2*pi/LambdaC*n(1);
ti=(2*ni)/(ni+n(1));
ri=(ni-n(1))/(ni+n(1));
Si(1,1)=1/ti;
Si(1,2)=ri/ti;
Si(2,1)=ri/ti;
Si(2,2)=1/ti;
E(:,1)=inv(Si)*Ei;
yk=real(E(1,1)*exp(-i*kp*xk)+E(2,1)*exp(i*kp*xk));
x=[x,xk];
y=[y,yk];
%%%
% mid layers of first DBR
for k=2:N
    xk=l:d(k)/1000:d(k)+l;
    kp=2*pi/LambdaC*n(k);
    tk=(2*n(k-1))/(n(k-1)+n(k));
    rk=(n(k-1)-n(k))/(n(k-1)+n(k));
    deltak=((2*pi/LambdaC)*n(k-1)*d(k-1));
    Sk(1,1)=(1/tk)*exp(i*deltak);
    Sk(1,2)=(rk/tk)*exp(i*deltak);
    Sk(2,1)=(rk/tk)*exp(-i*deltak);
    Sk(2,2)=(1/tk)*exp(-i*deltak);
    E(:,k)=inv(Sk)*E(:,k-1);
    yk=real(E(1,k)*exp(-i*kp*xk)*exp(i*kp*l)+E(2,k)*exp(i*kp*xk)*exp(-i*kp*l));
    l=l+d(k);
    x=[x,xk];
    y=[y,yk];
end
%%%
% Cavity layer
xc=l:dc/1000:l+dc;
kp=2*pi/LambdaC*nc;
tfc=(2*n(N))/(n(N)+nc);
rfc=(n(N)-nc)/(n(N)+nc);
deltaN=((2*pi/LambdaC)*n(N)*d(N));
Sfc(1,1)=(1/tfc)*exp(i*deltaN);
Sfc(1,2)=(rfc/tfc)*exp(i*deltaN);
Sfc(2,1)=(rfc/tfc)*exp(-i*deltaN);
Sfc(2,2)=(1/tfc)*exp(-i*deltaN);
Ec=inv(Sfc)*E(:,N);
yc=real(Ec(1)*exp(-i*kp*xc)*exp(i*kp*l)+Ec(2)*exp(i*kp*xc)*exp(-i*kp*l));
l=l+dc;
x=[x,xc];
y=[y,yc];
%first layer of second DBR
xk=l:d(1)/1000:d(1)+l;
kp=2*pi/LambdaC*n(1);
t1=(2*nc)/(nc+n(1));
r1=(nc-n(1))/(nc+n(1));
deltac=((2*pi/LambdaC)*nc*dc);
Sc(1,1)=1/t1*exp(i*deltac);
Sc(1,2)=r1/t1*exp(i*deltac);
Sc(2,1)=r1/t1*exp(-i*deltac);
Sc(2,2)=1/t1*exp(-i*deltac);
E(:,1)=inv(Sc)*Ec;
yk=real(E(1,1)*exp(-i*kp*xk)*exp(i*kp*l)+E(2,1)*exp(i*kp*xk)*exp(-i*kp*l));
l=l+d(1);
x=[x,xk];
y=[y,yk];
% mid layers of second DBR
for k=2:N
    xk=l:d(k)/1000:d(k)+l;
    kp=2*pi/LambdaC*n(k);
    tk=(2*n(k-1))/(n(k-1)+n(k));
    rk=(n(k-1)-n(k))/(n(k-1)+n(k));
    deltak=((2*pi/LambdaC)*n(k-1)*d(k-1));
    Sk(1,1)=(1/tk)*exp(i*deltak);
    Sk(1,2)=(rk/tk)*exp(i*deltak);
    Sk(2,1)=(rk/tk)*exp(-i*deltak);
    Sk(2,2)=(1/tk)*exp(-i*deltak);
    E(:,k)=inv(Sk)*E(:,k-1);
    yk=real(E(1,k)*exp(-i*kp*xk)*exp(i*kp*l)+E(2,k)*exp(i*kp*xk)*exp(-i*kp*l));
    l=l+d(k);
    x=[x,xk];
    y=[y,yk];
end
% final medium
xf=l:LambdaC/4000:l+LambdaC;
kp=2*pi/LambdaC*nf;
tf=(2*n(N))/(n(N)+nf);
rf=(n(N)-nf)/(n(N)+nf);
deltaf=((2*pi/LambdaC)*n(N)*d(N));
Sf(1,1)=(1/tf)*exp(i*deltaf);
Sf(1,2)=(rf/tf)*exp(i*deltaf);
Sf(2,1)=(rf/tf)*exp(-i*deltaf);
Sf(2,2)=(1/tf)*exp(-i*deltaf);
Ef=inv(Sf)*E(:,N);
yf=real(Ef(1)*exp(-i*kp*xf)*exp(i*kp*l)+Ef(2)*exp(i*kp*xf)*exp(-i*kp*l));
l=l+dc;
x=[x,xf];
y=[y,yf];
%% plotting Result
cla(handles.graph);
hold on
xlabel('x (nm)','fontweight','bold');
ylabel('Electric Field (V/m)','fontweight','bold');
plot(x,y);
end
