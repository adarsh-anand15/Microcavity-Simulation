function parameters=getdata(handles)
% function to get parameters from GUI
parameters.thetai=str2num(get(handles.thetai,'string'))*pi/180;%30*pi/180; %angle of incidence
parameters.Ei=str2num(get(handles.Ei,'string'));% Initial Electric field amplitude
parameters.thetaEi=str2num(get(handles.thetaEi,'string'));% Angle between Electric field and plane of incidence
parameters.ni=str2num(get(handles.ni,'string'));%1; % initial medium
parameters.nf=str2num(get(handles.nf,'string'));%1; % final medium
parameters.N_1=str2num(get(handles.N_1,'string'));%11; % No. of layers for one DBR1
parameters.N_2=str2num(get(handles.N_2,'string'));%11; % No. of layers for one DBR2
parameters.n1=str2num(get(handles.n1,'string'));% 2.02; % Refractive index of medium 1
parameters.n2=str2num(get(handles.n2,'string'));%1.46; %Refractive index of medium 2
parameters.nc= str2num(get(handles.nc,'string'));%n2; % Refractive index of medium of cavity
parameters.LambdaC=str2num(get(handles.LambdaC,'string'));%530; % central wavelength
parameters.d1=parameters.LambdaC/(4*parameters.n1); % Thickness of layer 1
parameters.d2=parameters.LambdaC/(4*parameters.n2); % Thickness of layer 2
parameters.dc=parameters.LambdaC/(2*parameters.nc); % Thickness of cavity layer
end