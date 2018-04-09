function [n,d,theta]=DSM(N_1,N_2,ni,nf,n1,n2,d1,d2,thetai)
%
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
end