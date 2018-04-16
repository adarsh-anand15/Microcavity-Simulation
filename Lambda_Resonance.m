function [LambdaCRs,LambdaCRp]=Lambda_Resonance(MicrocavityS,LambdaCtheta)
Lambda=LambdaCtheta;
Rs=1;

while Rs>0.8
    [Rs,~]=Reflectivity_calc(MicrocavityS,Lambda,1);
    Lambda=Lambda+0.001;
end
Lambda=Lambda-0.001;
Rs0=Rs+0.1;
while Rs<Rs0
    Rs0=Rs;
    [Rs,~]=Reflectivity_calc(MicrocavityS,Lambda,1);
    Lambda=Lambda+0.0001;
end
LambdaCRs=Lambda-0.0001;
Rp=1;
Lambda=LambdaCtheta;
while Rp>0.5
    [~,Rp]=Reflectivity_calc(MicrocavityS,Lambda,1);
    Lambda=Lambda+0.01;
end
Lambda=Lambda-0.01;
Rp0=Rp+0.1;
while Rp<Rp0
    Rp0=Rp;
    [~,Rp]=Reflectivity_calc(MicrocavityS,Lambda,1);
    Lambda=Lambda+0.001;
end
LambdaCRp=Lambda-0.001;
end