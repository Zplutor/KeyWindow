#import <Foundation/Foundation.h>
#import "ZAFAxSystemWideObject.h"

@interface ZAFAxService : NSObject

+ (BOOL)isCurrentApplicationTrusted;

+ (void)promptForTrustingCurrentApplicationIfNot;

+ (ZAFAxSystemWideObject*)systemWideAccessibilityObject;

@end
