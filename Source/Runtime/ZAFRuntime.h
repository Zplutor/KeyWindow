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

@end
