function DBR_field_profile(app)
%Field Profile of DBR
%% Initialization of various parameters
paraD=getdataD(app);
paraD.thetai=0;
app.D_thetai.Value=paraD.thetai;
app.D_thetaEi.Value=90;
LambdaC=paraD.LambdaC;
%% defining structure
DBRS=DS_DBR(paraD);
%% setting axes
c=physconst('LightSpeed');
ymin=0;
ymax=0;
for t = 0:0.1*LambdaC/(4*c):LambdaC/(4*c)
[~,y]=Stack_field_profile(DBRS,LambdaC,paraD.Ei,t);
ymint=min(y);
ymaxt=max(y);
ymin=min(ymin,ymint);
ymax=max(ymax,ymaxt);
end
ylimit=max(ymax,abs(ymin));
hold(app.graph_DBR,'on');
ylim(app.graph_DBR,[-ylimit ylimit]);
t=0;
while app.D_state.Value==1
    %% getting field profile
    [x,y]=Stack_field_profile(DBRS,LambdaC,paraD.Ei,t);
    t=t+0.1*LambdaC/(4*c);
    tleg=t*4*c/(LambdaC);
    tlegs=[num2str(tleg,'%.2f'),'*LambdaC/(4c)'];
    leg = ['t = ',tlegs];
    %% plot
    cla(app.graph_DBR);
    title(app.graph_DBR,'Electric Field Profile of a DBR');
    xlabel(app.graph_DBR,'x (nm)','fontweight','bold');
    ylabel(app.graph_DBR,'Electric Field (V/m)','fontweight','bold');
    plot(app.graph_DBR,x,y,'b-');
    legend(app.graph_DBR,leg);
    pause(0.1);
end
hold(app.graph_DBR,'off');
app.D_thetai.Value=30;
app.D_thetaEi.Value=45;
end