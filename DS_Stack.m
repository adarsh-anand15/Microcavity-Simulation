function StackS=DS_Stack(paraM)
% function to define structure of microcavity
%% calculation of various parameters
thetac = asin(paraM.ni/paraM.nc*sin(paraM.thetai)); % angle of propagation in the cavity
thetaf=asin(paraM.ni/paraM.nf*sin(paraM.thetai)); % exit angle 
%%%
%% defining structure
N=paraM.D1.N+paraM.D2.N+1;
n=zeros(1,N+2);
d=zeros(1,N+2);
theta=zeros(1,N+2);
% initial medium
n(1)=paraM.ni;
d(1)=0;
theta(1)=paraM.thetai;
%%%
% DBR1
for m = 2:paraM.D1.N+1
    if rem(m,2)==0
        n(m)=paraM.D1.n1; % may introduce disorder later
        d(m)=paraM.D1.d1; % may introduce disorder later
    else
        n(m)=paraM.D1.n2;
        d(m)=paraM.D1.d2;
    end   
    theta(m)=asin(paraM.ni/n(m)*sin(paraM.thetai));
end
%%%
% cavity layer
n(paraM.D1.N+2)=paraM.nc;
d(paraM.D1.N+2)=paraM.dc;
theta(paraM.D1.N+2)=thetac;
% DBR2
for m = paraM.D1.N+3:N+1
    if rem(m,2)==0
        n(m)=paraM.D2.n1; % may introduce disorder later
        d(m)=paraM.D2.d1; % may introduce disorder later
    else
        n(m)=paraM.D2.n2;
        d(m)=paraM.D2.d2;
    end   
    theta(m)=asin(paraM.ni/n(m)*sin(paraM.thetai));
end
% final layer
n(paraM.D1.N+paraM.D2.N+3)=paraM.nf;
d(paraM.D1.N+paraM.D2.N+3)=0;
theta(paraM.D1.N+paraM.D2.N+3)=thetaf;
%%%
%% Total Number of layers
StackS.n=n;
StackS.d=d;
StackS.theta=theta;
StackS.N=N;
end