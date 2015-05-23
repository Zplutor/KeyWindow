#import "ZAFLoginItem.h"


@interface ZAFLoginItem () {

    LSSharedFileListItemRef _handle;
}

@end



@implementation ZAFLoginItem


- (id)initWithHandle:(LSSharedFileListItemRef)handle {
    
    NSParameterAssert(handle != NULL);
    
    self = [super init];
    if (self) {
        
        _handle = handle;
    }
    return self;
}


- (void)dealloc {
    
    if (_handle != NULL) {
        CFRelease(_handle);
    }
}


- (LSSharedFileListItemRef)handle {
    
    return _handle;
}


- (NSURL*)url {
    
    CFURLRef url = LSSharedFileListItemCopyResolvedURL(_handle, kLSSharedFileListNoUserInteraction, NULL);
    if (url == NULL) {
        return nil;
    }
    
    return CFBridgingRelease(url);
}


@end
