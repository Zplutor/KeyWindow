#import <Foundation/Foundation.h>


@interface ZAFLoginItem : NSObject


- (id)initWithHandle:(LSSharedFileListItemRef)handle;

- (LSSharedFileListItemRef)handle;

- (NSURL*)url;


@end
