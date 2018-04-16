function M_field_profile(app)
%Field Profile of Microcavity%
%% Initialization of various parameters
paraM=getdataM(app);
%% defining structure
StackS=DS_Stack(paraM);
%% Finding Characteristic matrices
[Ss,Sp] = CMatrices(MicrocavityS,Lambda,nLambda );
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
    yk=real(E(1,k)*exp(-1i*kp*xk)*exp(i*kp*l)+E(2,k)*exp(i*kp*xk)*exp(-i*kp*l));
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
Sfc(1,1)=(1/tfc)*exp(1i*deltaN);
Sfc(1,2)=(rfc/tfc)*exp(1i*deltaN);
Sfc(2,1)=(rfc/tfc)*exp(-1i*deltaN);
Sfc(2,2)=(1/tfc)*exp(-1i*deltaN);
Ec=inv(Sfc)*E(:,N);
yc=real(Ec(1)*exp(-1i*kp*xc)*exp(1i*kp*l)+Ec(2)*exp(1i*kp*xc)*exp(-1i*kp*l));
l=l+dc;
x=[x,xc];
y=[y,yc];
%first layer of second DBR
xk=l:d(1)/1000:d(1)+l;
kp=2*pi/LambdaC*n(1);
t1=(2*nc)/(nc+n(1));
r1=(nc-n(1))/(nc+n(1));
deltac=((2*pi/LambdaC)*nc*dc);
Sc(1,1)=1/t1*exp(1i*deltac);
Sc(1,2)=r1/t1*exp(1i*deltac);
Sc(2,1)=r1/t1*exp(-1i*deltac);
Sc(2,2)=1/t1*exp(-1i*deltac);
E(:,1)=inv(Sc)*Ec;
yk=real(E(1,1)*exp(-1i*kp*xk)*exp(1i*kp*l)+E(2,1)*exp(1i*kp*xk)*exp(-1i*kp*l));
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
    Sk(1,1)=(1/tk)*exp(1i*deltak);
    Sk(1,2)=(rk/tk)*exp(1i*deltak);
    Sk(2,1)=(rk/tk)*exp(-1i*deltak);
    Sk(2,2)=(1/tk)*exp(-1i*deltak);
    E(:,k)=inv(Sk)*E(:,k-1);
    yk=real(E(1,k)*exp(-1i*kp*xk)*exp(1i*kp*l)+E(2,k)*exp(1i*kp*xk)*exp(-1i*kp*l));
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
Sf(1,1)=(1/tf)*exp(1i*deltaf);
Sf(1,2)=(rf/tf)*exp(1i*deltaf);
Sf(2,1)=(rf/tf)*exp(-1i*deltaf);
Sf(2,2)=(1/tf)*exp(-1i*deltaf);
Ef=inv(Sf)*E(:,N);
yf=real(Ef(1)*exp(-1i*kp*xf)*exp(1i*kp*l)+Ef(2)*exp(1i*kp*xf)*exp(-1i*kp*l));
l=l+dc;
x=[x,xf];
y=[y,yf];
%% plotting Result
cla(app.graph_MCavity);
hold(app.graph_MCavity);
title(app.graph_MCavity,'Electric Field Profile');
xlabel(app.graph_MCavity,'x (nm)','fontweight','bold');
ylabel(app.graph_MCavity,'Electric Field (V/m)','fontweight','bold');
plot(app.graph_MCavity,x,y);
hold(app.graph_MCavity);
clc;
end
