function Cp = diff1b(C,m)

Q = length(C);
C = C(:)';

Cp = zeros(Q, 1);
for n = m+1:Q-m
    for k = -m:m
        Cp(n) = Cp(n) + k*C(n+k);
    end
end

Cp = Cp / sum((-m:m).*(-m:m));
Cp = Cp(m+1:end-m);