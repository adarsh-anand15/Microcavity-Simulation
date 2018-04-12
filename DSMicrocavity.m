function MicrocavityS=DSMicrocavity(parameters)
% function to define structure of microcavity
%% calculation of various parameters
%theta1 = asin(ni/n1*sin(thetai)); % angle of propagation in the medium "1"
%theta2 = asin(ni/n2*sin(thetai)); % angle of propagation in the medium "2"
thetac = asin(parameters.ni/parameters.nc*sin(parameters.thetai)); % angle of propagation in the cavity
thetaf=asin(parameters.ni/parameters.nf*sin(parameters.thetai)); % exit angle 
%%%
%% defining structure
n=zeros(1,parameters.N_1+parameters.N_2+3);
d=zeros(1,parameters.N_1+parameters.N_2+3);
theta=zeros(1,parameters.N_1+parameters.N_2+3);
% initial medium
n(1)=parameters.ni;
d(1)=0;
theta(1)=parameters.thetai;
%%%
% DBR1
for m = 2:parameters.N_1+1
    if rem(m,2)==0
        n(m)=parameters.n1; % may introduce disorder later
        d(m)=parameters.d1; % may introduce disorder later
    else
        n(m)=parameters.n2;
        d(m)=parameters.d2;
    end   
    theta(m)=asin(parameters.ni/n(m)*sin(parameters.thetai));
end
%%%
% cavity layer
n(parameters.N_1+2)=parameters.nc;
d(parameters.N_1+2)=parameters.dc;
theta(parameters.N_1+2)=thetac;
% DBR2
for m = parameters.N_1+3:parameters.N_1+parameters.N_2+2
    if rem(m,2)==0
        n(m)=parameters.n1; % may introduce disorder later
        d(m)=parameters.d1; % may introduce disorder later
    else
        n(m)=parameters.n2;
        d(m)=parameters.d2;
    end   
    theta(m)=asin(parameters.ni/n(m)*sin(parameters.thetai));
end
% final layer
n(parameters.N_1+parameters.N_2+3)=parameters.nf;
d(parameters.N_1+parameters.N_2+3)=0;
theta(parameters.N_1+parameters.N_2+3)=thetaf;
%%%
%% Total Number of layers
MicrocavityS.n=n;
MicrocavityS.d=d;
MicrocavityS.theta=theta;
MicrocavityS.N=parameters.N_1+parameters.N_2+1;
end