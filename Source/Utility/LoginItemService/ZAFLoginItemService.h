#import <Foundation/Foundation.h>
#import "ZAFLoginItem.h"


@interface ZAFLoginItemService : NSObject

+ (ZAFLoginItemService*)defaultService;

- (NSArray*)loginItems;

- (ZAFLoginItem*)addOrUpdateLoginItemWithUrl:(NSURL*)url
                                  setOptions:(NSDictionary*)setOptions
                                clearOptions:(NSArray*)clearOptions;

- (BOOL)deleteLoginItem:(ZAFLoginItem*)loginItem;

@end
