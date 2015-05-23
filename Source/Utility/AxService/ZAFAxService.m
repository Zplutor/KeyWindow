#import "ZAFAxService.h"
#import "ZAFAxSystemWideObject.h"


@implementation ZAFAxService


+ (BOOL)isCurrentApplicationTrusted {
    return AXIsProcessTrusted();
}


+ (void)promptForTrustingCurrentApplicationIfNot {
    
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionaryAddValue(options, kAXTrustedCheckOptionPrompt, kCFBooleanTrue);
    
    AXIsProcessTrustedWithOptions(options);
    
    CFRelease(options);
}


+ (ZAFAxObject*)systemWideAccessibilityObject {
    
    AXUIElementRef handle = AXUIElementCreateSystemWide();
    if (handle == NULL) {
        return nil;
    }

    return [[ZAFAxSystemWideObject alloc] initWithHandle:handle];
}


- (id)init {
    NSAssert(NO, @"Cannot create instance of ZAFAxService.");
    return nil;
}


@end
