#import <Cocoa/Cocoa.h>


@class ZAFLayoutItem;


@interface ZAFLayoutItemViewController : NSViewController

+ (ZAFLayoutItemViewController*)create;

- (void)setSuperView:(NSView*)superView;
- (void)focus;
- (void)setEditable:(BOOL)isEditable;

- (ZAFLayoutItem*)layoutItem;
- (void)setLayoutItem:(ZAFLayoutItem*)layoutItem;

@end
