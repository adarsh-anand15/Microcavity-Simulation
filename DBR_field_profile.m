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
t=0;
ylim(app.graph_DBR,[-15 15]);
while app.D_state.Value==1
    %% getting field profile
    [x,y]=Stack_field_profile(DBRS,LambdaC,paraD.Ei,t);
    t=t+0.1;
    %% plot
    cla(app.graph_DBR);
    title(app.graph_DBR,'Electric Field Profile of a DBR');
    xlabel(app.graph_DBR,'x (nm)','fontweight','bold');
    ylabel(app.graph_DBR,'Electric Field (V/m)','fontweight','bold');
    plot(app.graph_DBR,x,y,'g-');
    pause(0.1);
end
%hold(app.graph_DBR,'off');
app.D_thetai.Value=30;
app.D_thetaEi.Value=45;
end