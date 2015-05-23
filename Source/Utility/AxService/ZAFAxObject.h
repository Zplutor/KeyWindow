#import <Foundation/Foundation.h>

@interface ZAFAxObject : NSObject

- (id)initWithHandle:(AXUIElementRef)handle;

- (AXUIElementRef)handle;

@end
