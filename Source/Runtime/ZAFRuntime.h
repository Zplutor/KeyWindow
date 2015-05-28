#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@class ZAFLayoutItem;


@interface ZAFRuntime : NSObject

+ (ZAFRuntime*)defaultRuntime;

- (void)start;
- (void)terminate;

- (NSArray*)allLayoutItems;
- (ZAFLayoutItem*)layoutItemWithIdentifier:(NSString*)identifier;

- (BOOL)addLayoutItem:(ZAFLayoutItem*)layoutItem;
- (BOOL)updateLayoutItem:(ZAFLayoutItem*)layoutItem;
- (BOOL)deleteLayoutItem:(ZAFLayoutItem*)layoutItem;

/**
 获取指定的布局项是否生效的指示值。
 */
- (BOOL)isEffectedLayoutItemWithIdentifier:(NSString*)identifier;

@end
