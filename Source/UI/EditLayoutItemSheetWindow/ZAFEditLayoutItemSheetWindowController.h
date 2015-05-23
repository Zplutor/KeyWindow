#import <Cocoa/Cocoa.h>


@class ZAFLayoutItem;


@protocol ZAFEditLayoutItemSheetWindowControllerDelegate <NSObject>

- (void)editLayoutItemSheetWindowControllerDidFinishEditing;
- (void)editLayoutItemSheetWindowControllerDidCancelEditing;

@end


/**
 用来编辑布局项的视图。
 */
@interface ZAFEditLayoutItemSheetWindowController : NSWindowController

+ (ZAFEditLayoutItemSheetWindowController*)create;

@property (nonatomic, weak) id<ZAFEditLayoutItemSheetWindowControllerDelegate> delegate;


- (void)setEditable:(BOOL)isEditable;


/**
 获取正在编辑的布局项。
 
 @post 返回值不为nil。
 */
- (ZAFLayoutItem*)layoutItem;


/**
 设置要编辑的布局项。
 
 @pre 设置值不为nil。
 */
- (void)setLayoutItem:(ZAFLayoutItem*)layoutItem;


@end
