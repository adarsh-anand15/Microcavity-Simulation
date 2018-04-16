function parametersM=getdataM(app)
% function to get Microcavity parameters from GUI
%% general
parametersM.thetai=app.M_thetai.Value*pi/180;%30*pi/180; %angle of incidence
parametersM.Ei=app.M_Ei.Value;% Initial Electric field amplitude
parametersM.thetaEi=app.M_thetaEi.Value;% Angle between Electric field and plane of incidence
parametersM.ni=app.M_ni.Value;%1; % initial medium
parametersM.nf=app.M_nf.Value;%1; % final medium
parametersM.LambdaC=app.M_LambdaC.Value; %530; % central wavelength
%%%
%% DBR1
parametersM.D1_n1=app.M_D1_n1.Value; 
parametersM.D1_n2=app.M_D1_n2.Value;
parametersM.D1_N=app.M_D1_N.Value;
parametersM.D1_d1=parametersM.LambdaC/(4*parametersM.D1_n1); % Thickness of layer 1
app.M_D1_d1.Value=parametersM.D1_d1;
parametersM.D1_d2=parametersM.LambdaC/(4*parametersM.D1_n2); % Thickness of layer 2
app.M_D1_d2.Value=parametersM.D1_d2;
%%%
%% DBR2
parametersM.D2_n1=app.M_D2_n1.Value;%11; % No. of layers for one DBR1
parametersM.D2_n2=app.M_D2_n2.Value;
parametersM.D2_N=app.M_D2_N.Value;
parametersM.D2_d1=parametersM.LambdaC/(4*parametersM.D2_n1); % Thickness of layer 1
app.M_D2_d1.Value=parametersM.D2_d1;
parametersM.D2_d2=parametersM.LambdaC/(4*parametersM.D2_n2); % Thickness of layer 2
app.M_D2_d2.Value=parametersM.D2_d2;
%% Cavity layer
parametersM.nc= app.M_nc.Value;%n2; % Refractive index of medium of cavity
parametersM.dc=parametersM.LambdaC/(2*parametersM.nc); % Thickness of cavity layer
app.M_dc.Value=parametersM.dc;
end