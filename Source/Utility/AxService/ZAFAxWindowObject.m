#import "ZAFAxWindowObject.h"


@implementation ZAFAxWindowObject


- (BOOL)getPosition:(NSPoint*)position {
    
    NSParameterAssert(position != NULL);
    
    AXValueRef positionObject = NULL;
    AXError error = AXUIElementCopyAttributeValue(self.handle, kAXPositionAttribute, (CFTypeRef*)&positionObject);
    if (error != kAXErrorSuccess) {
        return NO;
    }
    
    BOOL isSucceeded = AXValueGetValue(positionObject, kAXValueCGPointType, position);
    CFRelease(positionObject);
    return isSucceeded;
}


- (BOOL)setPosition:(NSPoint)position {
    
    AXValueRef positionObject = AXValueCreate(kAXValueCGPointType, &position);
    AXError error = AXUIElementSetAttributeValue(self.handle, kAXPositionAttribute, positionObject);
    CFRelease(positionObject);
    return error == kAXErrorSuccess;
}


- (BOOL)getSize:(NSSize*)size {
    
    AXValueRef sizeObject = NULL;
    AXError error = AXUIElementCopyAttributeValue(self.handle, kAXSizeAttribute, (CFTypeRef*)&sizeObject);
    if (error != kAXErrorSuccess) {
        return NO;
    }
    
    BOOL isSucceeded = AXValueGetValue(sizeObject, kAXValueCGSizeType, size);
    CFRelease(sizeObject);
    return isSucceeded;
}


- (BOOL)setSize:(NSSize)size {
    
    AXValueRef sizeObject = AXValueCreate(kAXValueCGSizeType, &size);
    AXError error = AXUIElementSetAttributeValue(self.handle, kAXSizeAttribute, sizeObject);
    CFRelease(sizeObject);
    return error == kAXErrorSuccess;
}


@end
