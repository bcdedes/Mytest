function g = cubicInterpolate( x, scale )
%cubicInterpolate Cubic convolution interpolation in 1D.
    % G = cubicInterpolate(X, SCALE) returns a signal that has (SCALE-1)
    % interpolated points in between original samples of X.

n_x = length(x);
n_g = (n_x-1)*scale + 1; % length of interpolated signal
g = zeros(1,n_g); % interpolated singal with n_g sample points

g(1) = x(1);

% apply boundary condition equations for interpolation points between x1
% and x2 (when g is a point in the subinterval of first and second inputs)
for i = 2:scale % up to, but not including, second input
    x_idx = 1;
    d = mod(((i-1)/scale),1);
    if d == 0
        g(i) = x(x_idx);
    else    
        g(i) = [(3*x(1) - 3*x(2) + x(3)) x(x_idx : x_idx+2)]*cubicCoeffs(d)';
    end
end

% For interpolation points between second input and second from last input
for i = scale+1:n_g - scale-1
    % for any subinterval [x[j] x[j+1]], 4 ck's, c[k-1] c[k] c[k+1] c[k+2], 
    % are [x[j-1] x[j] x[j+1] x[j+2]]
    x_idx = ceil(i/scale);
    d = mod(((i-1)/scale),1);
    if d == 0
        g(i) = x(x_idx);
    else
        g(i) = x(x_idx-1 : x_idx + 2)*cubicCoeffs(d)'; % eqn. 16 in paper
    end
end

% apply boundary condition equations for interpolation points between
% x(N-1) and x(N)
for i = n_g - scale:n_g-1
    x_idx = ceil(i/scale);
    d = mod(((i-1)/scale),1);
    if d == 0
        g(i) = x(x_idx);
    else
        g(i) = [x(x_idx-1: x_idx +1) (3*x(n_x) - 3*x(n_x-1) + x(n_x-2))]*cubicCoeffs(d)';
    end
end
g(n_g) = x(n_x);
end

%% Cubic convolution coefficeints for a uniformly sampled signal
function c = cubicCoeffs( s )
%cubicCoeffs cubic convolution coefficients
%   This function does compute the terms of the cubic convolution 
%   function (listed right after equation (25) in the paper Keys,
%   "Cubic Convolution Interpolation for Digital Image Processing,"
%   IEEE Transactions on Acoustics, Speech, and Signal Processing,
%   Vol. ASSP-29, No. 6, December 1981, p. 1155.
%
% c0 = -x^3/2 + x^2 - x/2;
% c1 = (3*x^3)/2 - (5*x^2)/2 + 1;
% c2 = -(3*x^3)/2 + 2*x^2 + x/2;
% c3 = x^3/2 - x^2/2;

a = -0.5;
c0 = ((a*(s + 1) - 5*a)*(s + 1) + 8*a)*(s + 1) - 4*a;
c1 = ((a + 2)*s - (a + 3))*s*s + 1;
c2 = ((a + 2)*(1 - s) - (a + 3))*(1 - s)*(1 - s) + 1;
c3 = 1 - c0 - c1 - c2;

c = [c0 c1 c2 c3];
end

%% Cubic convolution kernel
function f = cubic(x)
% See Keys, "Cubic Convolution Interpolation for Digital Image
% Processing," IEEE Transactions on Acoustics, Speech, and Signal
% Processing, Vol. ASSP-29, No. 6, December 1981, p. 1155.

    absx = abs(x);
    absx2 = absx.^2;
    absx3 = absx.^3;
    f = (1.5*absx3 - 2.5*absx2 + 1) .* (absx <= 1) + ...
        (-0.5*absx3 + 2.5*absx2 - 4*absx + 2) .* ((1 < absx) & (absx <= 2));
end
