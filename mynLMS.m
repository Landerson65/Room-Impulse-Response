
function [ w, e] = mynLMS(M, N, B, x, d)
%takes in excitation signal and received signal to find filter coefficients
%of nLMS filter. 

w = zeros(M, 1);
dhat = zeros(N, 1);
e = zeros(N, 1);

for n = M:N
    xx = x(n:-1:n-M+1)';
    u = B./(xx'*xx);
    dhat(n) = (w'*xx);
    e(n) = d(n) - dhat(n);
    w = w + u*e(n)*xx;
end

end