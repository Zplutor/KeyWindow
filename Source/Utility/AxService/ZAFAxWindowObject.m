#import "ZAFAxWindowObject.h"


static BOOL ElementIsRole(AXUIElementRef elment, CFStringRef role);


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


- (BOOL)isSheet {
    
    return ElementIsRole(self.handle, kAXSheetRole);
}


- (ZAFAxWindowObject*)parentWindow {
    
    AXUIElementRef parentObject = NULL;
    AXError error = AXUIElementCopyAttributeValue(self.handle, kAXParentAttribute, (CFTypeRef*)&parentObject);
    if (error != kAXErrorSuccess) {
        return nil;
    }
    
    if (parentObject == NULL) {
        return nil;
    }
    
    if (! ElementIsRole(parentObject, kAXWindowRole)) {
        return nil;
    }
    
    return [[ZAFAxWindowObject alloc] initWithHandle:parentObject];
}


@end



static BOOL ElementIsRole(AXUIElementRef element, CFStringRef role) {
    
    CFStringRef elementRole = NULL;
    AXError error = AXUIElementCopyAttributeValue(element, kAXRoleAttribute, (CFTypeRef*)&elementRole);
    if (error != kAXErrorSuccess) {
        return NO;
    }
    
    CFComparisonResult compareResult = CFStringCompare(elementRole, role, 0);
    CFRelease(elementRole);
    return compareResult == kCFCompareEqualTo;
}
