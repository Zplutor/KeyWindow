#import "ZAFAxObject.h"


@interface ZAFAxObject () {
    
    AXUIElementRef _handle;
}

@end



@implementation ZAFAxObject


- (id)init {
    NSAssert(NO, @"Call initWithHandle: instead.");
    return nil;
}


- (id)initWithHandle:(AXUIElementRef)handle {
    
    NSParameterAssert(handle != NULL);
    
    self = [super init];
    if (self) {
        
        _handle = handle;
    }
    return self;
}


- (AXUIElementRef)handle {
    return _handle;
}

@end
