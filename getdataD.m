function paraD=getdataD(app)
% function to get Microcavity parameters from GUI
%% general
paraD.thetai=app.D_thetai.Value*pi/180;%30*pi/180; %angle of incidence
paraD.Ei=app.D_Ei.Value;% Initial Electric field amplitude
paraD.thetaEi=app.D_thetaEi.Value*pi/180;% Angle between Electric field and plane of incidence
paraD.ni=app.D_ni.Value;%1; % initial medium
paraD.nf=app.D_nf.Value;%1; % final medium
paraD.LambdaC=app.D_LambdaC.Value; %530; % central wavelength

%% DBR
paraD.LambdaD=app.D_LambdaD.Value;
paraD.n1=app.D_n1.Value; 
paraD.n2=app.D_n2.Value;
paraD.N=app.D_N.Value;
paraD.d1=paraD.LambdaD/(4*paraD.n1); % Thickness of layer 1
paraD.d2=paraD.LambdaD/(4*paraD.n2); % Thickness of layer 2
app.D_d1.Value=paraD.d1;
app.D_d2.Value=paraD.d2;
end