function Uvskparallel(app)
paraM=getdataM(app); % getting the parameters from GUI
theta=0:2*pi/180:60*pi/180;
n=numel(theta);
LambdaCRs=zeros(1,n);
LambdaCRp=zeros(1,n);
LambdaCR=zeros(1,n);
for z=1:n
    paraM.thetai=theta(z);
    app.M_thetai.Value=paraM.thetai*180/pi;
    LambdaCtheta=paraM.LambdaC*sqrt(1-paraM.ni^2*(sin(paraM.thetai))^2/paraM.nc^2);
    MicrocavityS=DS_Microcavity(paraM);
    [LambdaCRs(z),LambdaCRp(z),LambdaCR(z)]=Lambda_Resonance(MicrocavityS,LambdaCtheta,paraM.thetaEi);
end
h=6.626e-34;
c=physconst('LightSpeed');
Us=(h*c*1e9)./LambdaCRs;
Up=(h*c*1e9)./LambdaCRp;
U=(h*c*1e9)./LambdaCR;
kparallels=zeros(1,n);
kparallelp=zeros(1,n);
kparallel=zeros(1,n);
for z=1:n
    kparallels(z)=2*pi*sin(theta(z))/LambdaCRs(z);
    kparallelp(z)=2*pi*sin(theta(z))/LambdaCRp(z);
    kparallel(z)=2*pi*sin(theta(z))/LambdaCR(z);
end
cla(app.graph_MCavity);
hold(app.graph_MCavity);
ylim(app.graph_MCavity,'auto');
title(app.graph_MCavity,'Energy vs k(parallel)');
xlabel(app.graph_MCavity,'k(parallel) (nm^-1)','fontweight','bold');
ylabel(app.graph_MCavity,'Energy(J)','fontweight','bold');
plot(app.graph_MCavity,kparallels,Us,'r-');
plot(app.graph_MCavity,kparallelp,Up,'b-');
plot(app.graph_MCavity,kparallel,U,'g-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization','Total' );
hold(app.graph_MCavity);
end

