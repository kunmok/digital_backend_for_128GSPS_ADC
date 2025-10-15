
% Simple function that makes a prbs matrix from a set of coefficients
% Arguments:
%   length = the length of the PRBS
%   bits = number of bits the PRBS outputs per cycle
%   coefficients = prbs coefficients, given as a horizontal vector
function [ out ] = get_prbs_matrix( length, bits, coefficients )
% 
    if (size(coefficients, 1) ~= 1)
        error('Coefficients must be a horizontal vector')
    end
    if (size(coefficients, 2) ~= length)
        error('Length of coefficients vector must be equal to PRBS length')
    end
    
    % Pad coefficients with 0 if bits per cycle > PRBS length
    if (bits > length)
        coefficients = [coefficients zeros(1, bits - length)];
    end
    
    % Create Step matrix
    step = [coefficients; eye(max(length, bits) - 1, max(length, bits))];
    
    % Convert to galois
    out = gf(step, 2) ^ bits;
end

