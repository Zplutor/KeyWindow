#import <Cocoa/Cocoa.h>


@protocol ZAFPromptTrustSheetWindowControllerDelegate <NSObject>

- (void)promptTrustSheetWindowDidClose;

@end


@interface ZAFPromptTrustSheetWindowController : NSWindowController

+ (ZAFPromptTrustSheetWindowController*)create;

@property (nonatomic, weak) id<ZAFPromptTrustSheetWindowControllerDelegate> delegate;

@end
