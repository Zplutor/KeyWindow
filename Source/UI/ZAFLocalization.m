#import "ZAFLocalization.h"


NSString* ZAFGetLocalizedString(NSString* stringKey) {
    
    return [[NSBundle mainBundle] localizedStringForKey:stringKey value:[NSString string] table:@"KeyWindow"];
}