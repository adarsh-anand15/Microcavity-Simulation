function [Rs,Rp,R]=Reflectivity_calc(StackS,Lambda,nLambda)
%% Finding Characteristic matrices
[ Ss,Sp ] = CMatrices(StackS,Lambda,nLambda );
%% Reflectivity calculation
rs=Ss(2,1,:)./Ss(1,1,:);
rp=Sp(2,1,:)./Sp(1,1,:);
Rs=abs(rs(:)).^2;
Rp=abs(rp(:)).^2;
R=Rs.*(sin(StackS.theta(1)))^2+Rp.*(cos(StackS.theta(1)))^2;
end