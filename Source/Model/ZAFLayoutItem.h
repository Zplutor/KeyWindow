#import <Foundation/Foundation.h>


@class ZAFFrame;
@class ZAFHotKey;
@class ZAFMutableFrame;
@class ZAFMutableHotKey;


@interface ZAFLayoutItem : NSObject <NSCopying>

- (ZAFLayoutItem*)emptyLayoutItem;

- (NSString*)identifier;
- (NSString*)name;
- (ZAFHotKey*)hotKey;
- (ZAFFrame*)frame;

- (BOOL)isEmpty;

@end



@interface ZAFMutableLayoutItem : ZAFLayoutItem <NSMutableCopying>

- (void)setIdentifier:(NSString*)identifier;
- (void)setName:(NSString*)name;
- (void)setHotKey:(ZAFHotKey*)hotKey;
- (void)setFrame:(ZAFFrame*)frame;

@end
