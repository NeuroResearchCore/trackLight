function Cp = diff1(C,m)
%first order derivative

Q = length(C);
C = C(:)';

% Compute the 1st temporal derivative
Cp = zeros(Q, 1);
for n = m+1:Q-m
    for k = -m:m
        Cp(n) = Cp(n) + k*C(n+k);
    end
end

Cp = Cp / sum((-m:m).*(-m:m));
Cp = Cp;