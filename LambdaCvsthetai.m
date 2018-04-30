function LambdaCvsthetai(app)
paraM=getdataM(app); % getting the parameters from GUI
theta=-60*pi/180:2*pi/180:60*pi/180;
theta_deg=-60:2:60;
n=numel(theta);
LambdaCRs=zeros(1,n);
LambdaCRp=zeros(1,n);
LambdaCR=zeros(1,n);
for z=1:n
    paraM.thetai=theta(z);
    app.M_thetai.Value=theta_deg(z);
    LambdaCtheta=paraM.LambdaC*sqrt(1-paraM.ni^2*(sin(paraM.thetai))^2/paraM.nc^2);
    MicrocavityS=DS_Microcavity(paraM);
    [LambdaCRs(z),LambdaCRp(z),LambdaCR(z)]=Lambda_Resonance(MicrocavityS,LambdaCtheta,paraM.thetaEi);
end
cla(app.graph_MCavity);
hold(app.graph_MCavity,'on');
ylim(app.graph_MCavity,'auto');
title(app.graph_MCavity,'Lambda_Resonance vs theta');
xlabel(app.graph_MCavity,'Angle of Incidence(degrees)','fontweight','bold');
ylabel(app.graph_MCavity,'Resonance Wavelength (nm)','fontweight','bold');
plot(app.graph_MCavity,theta_deg,LambdaCRs,'r-');
plot(app.graph_MCavity,theta_deg,LambdaCRp,'b-');
%plot(app.graph_MCavity,theta,LambdaCR,'g-');
legend(app.graph_MCavity,'s-Polarization','p-Polarization' );
hold(app.graph_MCavity,'off');
end