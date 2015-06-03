#import <Cocoa/Cocoa.h>


@class ZAFLayoutItem;
@class ZAFLayoutItemListViewController;


@protocol ZAFLayoutItemListViewControllerListener <NSObject>
@required

- (void)layoutItemListViewControllerDidChangeSelection:(ZAFLayoutItemListViewController*)controller;
- (void)layoutItemListViewControllerDidDoubleClick:(ZAFLayoutItemListViewController*)controller;

@end


/**
 用于显示布局项的视图控制器。
 */
@interface ZAFLayoutItemListViewController : NSViewController

+ (ZAFLayoutItemListViewController*)create;

- (void)setSuperView:(NSView*)superView;

- (void)setListener:(id<ZAFLayoutItemListViewControllerListener>)listener;

- (void)addLayoutItems:(NSArray*)layoutItems;
- (void)addLayoutItem:(ZAFLayoutItem*)layoutItem;

- (BOOL)selectLayoutItemWithIdentifier:(NSString*)identifer;

- (BOOL)hasSelection;
- (ZAFLayoutItem*)selectedLayoutItem;
- (void)deleteSelectedLayoutItem;
- (void)updateSelectedLayoutItemWithNewLayoutItem:(ZAFLayoutItem*)layoutItem;

- (void)setEnabled:(BOOL)isEnabled;


@end
