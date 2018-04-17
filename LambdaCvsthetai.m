function LambdaCvsthetai(app)
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
cla(app.graph_MCavity);
hold(app.graph_MCavity);
ylim(app.graph_MCavity,'auto');
title(app.graph_MCavity,'LambdaC vs theta');
xlabel(app.graph_MCavity,'Angle of Incidence(Radians)','fontweight','bold');
ylabel(app.graph_MCavity,'Resonance Wavelength (nm)','fontweight','bold');
plot(app.graph_MCavity,theta,LambdaCRs,'r-');
plot(app.graph_MCavity,theta,LambdaCRp,'b-');
plot(app.graph_MCavity,theta,LambdaCR,'g-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization','Total' );
hold(app.graph_MCavity);
end