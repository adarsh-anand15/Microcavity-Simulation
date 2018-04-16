function Uvskparallel(app)
temp=app;
theta=0:2:70;
n=numel(theta);
LambdaCRs=[];
LambdaCRp=[];
for z=1:n
    temp.M_thetai.Value=theta(z);
    LambdaCtheta=temp.M_LambdaC.Value*sqrt(1-temp.M_ni.Value^2*(sin(temp.M_thetai.Value*pi/180))^2/temp.M_nc.Value^2);
    MicrocavityS=DS_Microcavity(temp);
    [temp1,temp2]=Lambda_Resonance(MicrocavityS,LambdaCtheta);
    LambdaCRs=[LambdaCRs,temp1];
    LambdaCRp=[LambdaCRp,temp2];
end
h=6.626e-34;
c=physconst('LightSpeed');
Us=(h*c)./LambdaCRs;
Up=(h*c)./LambdaCRp;
kparallels=zeros(1,n);
kparallelp=zeros(1,n);
for z=1:n
    kparallels(z)=2*pi*sin(theta(z)*pi/180)/LambdaCRs(z);
    kparallelp(z)=2*pi*sin(theta(z)*pi/180)/LambdaCRp(z);
end
cla(app.graph_MCavity);
hold(app.graph_MCavity);
title(app.graph_MCavity,'Energy vs k(parallel)');
xlabel(app.graph_MCavity,'k(parallel)','fontweight','bold');
ylabel(app.graph_MCavity,'Energy','fontweight','bold');
plot(app.graph_MCavity,kparallels,Us,'r-');
plot(app.graph_MCavity,kparallelp,Up,'b-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization' );
%plot(app.graph_MCavity,theta,LambdaCRs,'r-');
%plot(app.graph_MCavity,theta,LambdaCRp,'b-');
hold(app.graph_MCavity);
end

