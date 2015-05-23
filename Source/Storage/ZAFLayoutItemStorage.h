#import <Foundation/Foundation.h>


@class ZAFLayoutItem;


@interface ZAFLayoutItemStorage : NSObject

- (NSArray*)allLayoutItems;
- (ZAFLayoutItem*)layoutItemWithIdentifier:(NSString*)identifier;
- (BOOL)addLayoutItem:(ZAFLayoutItem*)item;
- (BOOL)updateLayoutItem:(ZAFLayoutItem*)item;
- (BOOL)deleteLayoutItemWithIdentifier:(NSString*)identifier;

@end
