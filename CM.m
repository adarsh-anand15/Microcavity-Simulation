function [ Ss,Sp ] = CM( N,n,d,theta,Lambda,nLambda )
%function to calculate characteristic matrices for stack of given structure
%   Detailed explanation goes here
% initializing as identity matrix
for z=1:nLambda+1;
        Ss(:,:,z)=eye(2);
        Sp(:,:,z)=eye(2);
end
%%%
% for each layer
for m=1:N+1
    deltam=((2*pi./Lambda)*n(m)*d(m)*cos(theta(m)));
    % for s polarization
    rms=((n(m)*cos(theta(m)))-(n(m+1)*cos(theta(m+1))))/((n(m)*cos(theta(m)))+(n(m+1)*cos(theta(m+1))));
    tms=(2*n(m)*cos(theta(m)))/(n(m)*cos(theta(m)+n(m+1)*cos(theta(m+1))));
    Sms(1,1,:)=(1/tms)*exp(1i*deltam);
    Sms(1,2,:)=(rms/tms)*exp(1i*deltam);
    Sms(2,1,:)=(rms/tms)*exp(-1i*deltam);
    Sms(2,2,:)=(1/tms)*exp(-1i*deltam);
    % for p polarization
    rmp=((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))-(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))))/((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))+(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))));
    tmp=(2*n(m)*n(m)*sin(theta(m))*cos(theta(m)))/((n(m)*n(m)*sin(theta(m))*cos(theta(m+1)))+(n(m+1)*n(m+1)*sin(theta(m+1))*cos(theta(m))));
    Smp(1,1,:)=(1/tmp)*exp(1i*deltam);
    Smp(1,2,:)=(rmp/tmp)*exp(1i*deltam);
    Smp(2,1,:)=(rmp/tmp)*exp(-1i*deltam);
    Smp(2,2,:)=(1/tmp)*exp(-1i*deltam);
    for z=1:nLambda+1
        Ss(:,:,z)=Ss(:,:,z)*Sms(:,:,z);
        Sp(:,:,z)=Sp(:,:,z)*Smp(:,:,z);
    end
end
%%%

end

