#import "ZAFUtilities.h"


double ZAFCorrectPercentValue(double percent) {
    
    if (percent < 0) {
        return 0;
    }
    else if (percent > 1) {
        return 1;
    }
    else {
        return percent;
    }
}