function [Rs,Rp]=Reflectivity_calc(MicrocavityS,Lambda,nLambda)
%% Finding Characteristic matrices
[ Ss,Sp ] = CMatrices(MicrocavityS,Lambda,nLambda );
%% Reflectivity calculation
rs=Ss(2,1,:)./Ss(1,1,:);
rp=Sp(2,1,:)./Sp(1,1,:);
Rs=abs(rs(:)).^2;
Rp=abs(rp(:)).^2;
end