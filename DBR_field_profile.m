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
while app.D_state.Value==1
    %% getting field profile
    [x,y]=Stack_field_profile(DBRS,LambdaC,paraD.Ei,t);
    t=t+0.1;
    %% plot
    %hold(app.graph_MCavity,'on');
    ylim(app.graph_DBR,[-12 12]);
    plot(app.graph_DBR,x,y,'g-');
    pause(0.1);
end
app.D_thetai.Value=30;
app.D_thetaEi.Value=45;
end