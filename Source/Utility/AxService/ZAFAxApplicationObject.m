#import "ZAFAxApplicationObject.h"

@implementation ZAFAxApplicationObject

- (ZAFAxWindowObject*)focusedWindow {
    
    AXUIElementRef handle = NULL;
    AXError error = AXUIElementCopyAttributeValue(self.handle,
                                                  kAXFocusedWindowAttribute,
                                                  (CFTypeRef*)&handle);

    if (error != kAXErrorSuccess) {
        return nil;
    }
    
    return [[ZAFAxWindowObject alloc] initWithHandle:handle];
}

@end
