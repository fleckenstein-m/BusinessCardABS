function [Year, Month, Day] = Convert_yyyymmdd(dateyyymmdd)

Year  = floor(dateyyymmdd./ 10000);
Month = floor(mod(dateyyymmdd, 10000) ./ 100);
Day   = floor(mod(dateyyymmdd, 100));

end