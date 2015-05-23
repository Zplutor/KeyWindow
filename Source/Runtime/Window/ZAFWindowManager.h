#import <Foundation/Foundation.h>


@class ZAFFrame;


@interface ZAFWindowManager : NSObject

- (BOOL)moveAndResizeFocusedWindowWithFrame:(ZAFFrame*)frame;

@end
