function Y=resampleivo(X,T,f,nY)
if nargin==3,
  nY=ceil(T(end)/f);                % nPoints is not given; estimate it.
end
    
Y=zeros(1,nY,'single');

TI=1:f;                             % Moving time window
for i=1:nY
  Y(i)=mean(X(T>=TI(1) & T<=TI(end))); % The mean of the elements fall in this time window
  TI=TI+f;                          % Move the time window
end