function [LambdaCRs,LambdaCRp,LambdaCR]=Lambda_Resonance(MicrocavityS,LambdaCtheta)
% Finding resonsnce wavelength
%%
Lambda=LambdaCtheta:0.01:LambdaCtheta+30;
nLambda=numel(Lambda);
[Rs,Rp,R]=Reflectivity_calc(MicrocavityS,Lambda,nLambda);
[~,Is]=min(Rs);
[~,Ip]=min(Rp);
[~,I]=min(R);
LambdaCRs=Lambda(Is);
LambdaCRp=Lambda(Ip);
LambdaCR=Lambda(I);
end