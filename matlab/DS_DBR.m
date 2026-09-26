function DBRS=DS_DBR(paraD)
% function to define structure of DBR
%% initialization
N=paraD.N;
n=zeros(1,N+2);
d=zeros(1,N+2);
theta=zeros(1,N+2);
%% initial medium
n(1)=paraD.ni;
d(1)=0;
theta(1)=paraD.thetai;
%% DBR
for m = 2:paraD.N+1
    if rem(m,2)==0
        n(m)=paraD.n1; % may introduce disorder later
        d(m)=paraD.d1; % may introduce disorder later
    else
        n(m)=paraD.n2;
        d(m)=paraD.d2;
    end   
    theta(m)=asin(paraD.ni/n(m)*sin(paraD.thetai));
end
%% final layer
n(paraD.N+2)=paraD.nf;
d(paraD.N+2)=0;
theta(paraD.N+2)=asin(paraD.ni/paraD.nf*sin(paraD.thetai));
%% Returning structure
DBRS.n=n;
DBRS.d=d;
DBRS.theta=theta;
DBRS.N=N;
end