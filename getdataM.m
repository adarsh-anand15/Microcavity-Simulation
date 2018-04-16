function paraM=getdataM(app)
% function to get Microcavity parameters from GUI
%% general
paraM.thetai=app.M_thetai.Value*pi/180;%30*pi/180; %angle of incidence
paraM.Ei=app.M_Ei.Value;% Initial Electric field amplitude
paraM.thetaEi=app.M_thetaEi.Value;% Angle between Electric field and plane of incidence
paraM.ni=app.M_ni.Value;%1; % initial medium
paraM.nf=app.M_nf.Value;%1; % final medium
paraM.LambdaC=app.M_LambdaC.Value; %530; % central wavelength
%%%
%% DBR1
paraM.D1.n1=app.M_D1_n1.Value; 
paraM.D1.n2=app.M_D1_n2.Value;
paraM.D1.N=app.M_D1_N.Value;
paraM.D1.d1=paraM.LambdaC/(4*paraM.D1.n1); % Thickness of layer 1
paraM.D1.d2=paraM.LambdaC/(4*paraM.D1.n2); % Thickness of layer 2
app.M_D1_d1.Value=paraM.D1.d1;
app.M_D1_d2.Value=paraM.D1.d2;
%%%
%% DBR2
paraM.D2.n1=app.M_D2_n1.Value;%11; % No. of layers for one DBR1
paraM.D2.n2=app.M_D2_n2.Value;
paraM.D2.N=app.M_D2_N.Value;
paraM.D2.d1=paraM.LambdaC/(4*paraM.D2.n1); % Thickness of layer 1
paraM.D2.d2=paraM.LambdaC/(4*paraM.D2.n2); % Thickness of layer 2
app.M_D2_d1.Value=paraM.D2.d1;
app.M_D2_d2.Value=paraM.D2.d2;
%% Cavity layer
paraM.nc= app.M_nc.Value;%n2; % Refractive index of medium of cavity
paraM.dc=paraM.LambdaC/(2*paraM.nc); % Thickness of cavity layer
app.M_dc.Value=paraM.dc;
end