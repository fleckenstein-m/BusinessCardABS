function [minval,midx] = minbygroup(val, validx)
  % return min value of val, index in input list vector (typically 1:length(val))
  [minval, midx] = min(val);    
  midx = validx(midx);
end