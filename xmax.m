function imax=xmax(p,beta)

if (beta>10) && (beta<100),
 p=p/sum(p);        % Normalize, to avoid overflow when exp
 p = exp(p*beta); 
 imax = find(rand < cumsum(p/sum(p)),1);
else
 [~,imax]=max(p);   % classical noiseless max
end