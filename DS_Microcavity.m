function MicrocavityS=DS_Microcavity(paraM)
% function to define structure of microcavity
%% initialization
N=paraM.D1.N+paraM.D2.N+1;
n=zeros(1,N+2);
d=zeros(1,N+2);
theta=zeros(1,N+2);
%% initial medium
n(1)=paraM.ni;
d(1)=0;
theta(1)=paraM.thetai;
%% DBR1
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
%% cavity layer
n(paraM.D1.N+2)=paraM.nc;
d(paraM.D1.N+2)=paraM.dc;
theta(paraM.D1.N+2)=asin(paraM.ni/paraM.nc*sin(paraM.thetai));
%% DBR2
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
%% final layer
n(paraM.D1.N+paraM.D2.N+3)=paraM.nf;
d(paraM.D1.N+paraM.D2.N+3)=0;
theta(paraM.D1.N+paraM.D2.N+3)=asin(paraM.ni/paraM.nf*sin(paraM.thetai));
%% Returning structure
MicrocavityS.n=n;
MicrocavityS.d=d;
MicrocavityS.theta=theta;
MicrocavityS.N=N;
end