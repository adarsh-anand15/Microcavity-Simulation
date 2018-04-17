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
t=0;
while app.M_state.Value==1
    %% getting field profile
    [x,y]=Stack_field_profile(MicrocavityS,LambdaC,paraM.Ei,t);
    t=t+0.1;
    %% plot
    %hold(app.graph_MCavity,'on');
    ylim(app.graph_MCavity,[-200 200]);
    plot(app.graph_MCavity,x,y,'g-');
    pause(0.1);
end
app.M_thetai.Value=30;
app.M_thetaEi.Value=45;
end
