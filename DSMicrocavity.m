function MicrocavityS=DSMicrocavity(app)
% function to define structure of microcavity
%% calculation of various parameters
%theta1 = asin(ni/n1*sin(thetai)); % angle of propagation in the medium "1"
%theta2 = asin(ni/n2*sin(thetai)); % angle of propagation in the medium "2"
thetac = asin(app.M_ni.Value/app.M_nc.Value*sin(app.M_thetai.Value*pi/180)); % angle of propagation in the cavity
thetaf=asin(app.M_ni.Value/app.M_nf.Value*sin(app.M_thetai.Value*pi/180)); % exit angle 
%%%
%% defining structure
N=app.M_D1_N.Value+app.M_D2_N.Value+1;
n=zeros(1,N+2);
d=zeros(1,N+2);
theta=zeros(1,N+2);
% initial medium
n(1)=app.M_ni.Value;
d(1)=0;
theta(1)=app.M_thetai.Value*pi/180;
%%%
% DBR1
for m = 2:app.M_D1_N.Value+1
    if rem(m,2)==0
        n(m)=app.M_D1_n1.Value; % may introduce disorder later
        d(m)=app.M_D1_d1.Value; % may introduce disorder later
    else
        n(m)=app.M_D1_n2.Value;
        d(m)=app.M_D1_d2.Value;
    end   
    theta(m)=asin(app.M_ni.Value/n(m)*sin(app.M_thetai.Value*pi/180));
end
%%%
% cavity layer
n(app.M_D1_N.Value+2)=app.M_nc.Value;
d(app.M_D1_N.Value+2)=app.M_dc.Value;
theta(app.M_D1_N.Value+2)=thetac;
% DBR2
for m = app.M_D1_N.Value+3:N+1
    if rem(m,2)==0
        n(m)=app.M_D2_n1.Value; % may introduce disorder later
        d(m)=app.M_D2_d1.Value; % may introduce disorder later
    else
        n(m)=app.M_D2_n2.Value;
        d(m)=app.M_D2_d2.Value;
    end   
    theta(m)=asin(app.M_ni.Value/n(m)*sin(app.M_thetai.Value*pi/180));
end
% final layer
n(app.M_D1_N.Value+app.M_D2_N.Value+3)=app.M_nf.Value;
d(app.M_D1_N.Value+app.M_D2_N.Value+3)=0;
theta(app.M_D1_N.Value+app.M_D2_N.Value+3)=thetaf;
%%%
%% Total Number of layers
MicrocavityS.n=n;
MicrocavityS.d=d;
MicrocavityS.theta=theta;
MicrocavityS.N=N;
end