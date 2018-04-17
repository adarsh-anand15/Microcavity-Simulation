function [x,y]=Stack_field_profile(StackS,LambdaC,Ei,t)
n=StackS.n;
d=StackS.d;
%theta=MicrocavityS.theta;
N=StackS.N;
d(N+2)=2*LambdaC;
c=physconst('LightSpeed');
w=c*2*pi/LambdaC;
%% Calculation of Ebi
E=zeros(2,N+2);
[S,~] = CMatrices(StackS,LambdaC,1);
r=S(2,1)/S(1,1); % Amplitude reflection coefficient
E(1,1)=Ei;
E(2,1)=r*E(1,1);
%% Collecting points to plot
%% initial medium
xi=-2*LambdaC:LambdaC/4000:0;
k=2*pi/LambdaC*n(1);
yi=real((E(1,1)*exp(-1i*k*xi)+E(2,1)*exp(1i*k*xi))*exp(1i*w*t));
x=xi;
y=yi;
%% Stack
l=0;
for m=1:N+1
    xm=l:d(m+1)/1000:d(m+1)+l;
    k=2*pi/LambdaC*n(m+1);
    deltam=((2*pi/LambdaC)*n(m)*d(m));
    rm=((n(m))-(n(m+1)))/((n(m))+(n(m+1)));
    tm=(2*n(m))/(n(m)+n(m+1));
    Sm(1,1)=(1/tm)*exp(1i*deltam);
    Sm(1,2)=(rm/tm)*exp(1i*deltam);
    Sm(2,1)=(rm/tm)*exp(-1i*deltam);
    Sm(2,2)=(1/tm)*exp(-1i*deltam);
    E(:,m+1)=Sm\E(:,m);
    ym=real((E(1,m+1)*exp(-1i*k*xm)*exp(1i*k*l)+E(2,m+1)*exp(1i*k*xm)*exp(-1i*k*l))*exp(1i*w*t));
    l=l+d(m+1);
    x=[x,xm];
    y=[y,ym];
end
end