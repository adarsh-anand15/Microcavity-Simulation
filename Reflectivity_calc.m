function [Rs,Rp]=Reflectivity_calc(MicrocavityS,Lambda,nLambda)
%% Finding Characteristic matrices
[ Ss,Sp ] = CMatrices(MicrocavityS,Lambda,nLambda );
%%%
%% Reflectivity calculation
% Initializing with zeros
%rs=zeros(1,nLambda+1);
%rp=zeros(1,nLambda+1);
%Rs=zeros(1,nLambda+1);
%Rp=zeros(1,nLambda+1);
%for z=1:nLambda+1
    rs=Ss(2,1,:)./Ss(1,1,:);
    rp=Sp(2,1,:)./Sp(1,1,:);
%end
%for z=1:nLambda+1
    Rs=abs(rs(:)).^2;
    Rp=abs(rp(:)).^2;
%end
%%%
end