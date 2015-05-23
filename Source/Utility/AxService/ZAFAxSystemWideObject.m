#import "ZAFAxSystemWideObject.h"


@implementation ZAFAxSystemWideObject


- (ZAFAxApplicationObject*)focusedApplication {
    
    AXUIElementRef handle = NULL;
    AXError error = AXUIElementCopyAttributeValue(self.handle,
                                                  kAXFocusedApplicationAttribute,
                                                  (CFTypeRef*)&handle);
    if (error != kAXErrorSuccess) {
        return nil;
    }

    return [[ZAFAxApplicationObject alloc] initWithHandle:handle];
}

@end
