function [n,d,theta]=DSM(N_1,N_2,ni,nf,n1,n2,nc,thetai,LambdaC)
% function to define structure of microcavity
%% calculation of various parameters
d1=LambdaC/(4*n1); % Thickness of layer 1
d2=LambdaC/(4*n2); % Thickness of layer 2
dc=LambdaC/(2*nc); % Thickness of cavity layer
%theta1 = asin(ni/n1*sin(thetai)); % angle of propagation in the medium "1"
%theta2 = asin(ni/n2*sin(thetai)); % angle of propagation in the medium "2"
thetac = asin(ni/nc*sin(thetai)); % angle of propagation in the cavity
thetaf=asin(ni/nf*sin(thetai)); % exit angle 
%%%
%% defining structure
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