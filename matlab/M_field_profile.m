function M_field_profile(app)
%Field Profile of Microcavity%
%% Initialization of various parameters
paraM=getdataM(app);
paraM.thetai=0;
app.M_thetai.Value=paraM.thetai;
app.M_thetaEi.Value=90;
LambdaC=paraM.LambdaC;
%% defining structure
MicrocavityS=DS_Microcavity(paraM);
%% setting axes
c=physconst('LightSpeed');
ymin=0;
ymax=0;
for t = 0:0.1*LambdaC/(4*c*paraM.nc):LambdaC/(c*paraM.nc)
[~,y]=Stack_field_profile(MicrocavityS,LambdaC,paraM.Ei,t);
ymint=min(y);
ymaxt=max(y);
ymin=min(ymin,ymint);
ymax=max(ymax,ymaxt);
end
ylimit=max(ymax,abs(ymin));
hold(app.graph_MCavity,'on');
ylim(app.graph_MCavity,[-ylimit ylimit]);
t=0;
while app.M_state.Value==1
    %% getting field profile
    [x,y]=Stack_field_profile(MicrocavityS,LambdaC,paraM.Ei,t);
    t=t+0.1*LambdaC/(4*c*paraM.nc);
    tleg=t*4*c*paraM.nc/(LambdaC);
    tlegs=[num2str(tleg,'%.2f'),'*LambdaC/(4c)'];
    leg = ['t = ',tlegs];
    %% plot
    cla(app.graph_MCavity);
    title(app.graph_MCavity,'Electric Field Profile of a Microcavity');
    xlabel(app.graph_MCavity,'x (nm)','fontweight','bold');
    ylabel(app.graph_MCavity,'Electric Field (V/m)','fontweight','bold');
    plot(app.graph_MCavity,x,y,'b-');
    legend(app.graph_MCavity,leg);
    pause(0.1);
end
hold(app.graph_MCavity,'off');
app.M_thetai.Value=30;
app.M_thetaEi.Value=45;
end
