function [idx, minVal] = findBandDelimiters(freq,delimiter)

[~, idx] = min(abs(freq-delimiter));
minVal  =   freq(idx);