#import <Foundation/Foundation.h>


/**
 修正百分比的值，使其落在[0, 1]区间内。
 
 若百分比的值小于0，返回0；若百分比的值大于1，返回1；其余情况返回原来的值。
 */
double ZAFCorrectPercentValue(double percent);