#import <Foundation/Foundation.h>

@class ZAFHotKey;


@protocol ZAFHotKeyListener <NSObject>

- (void)hotKeyDidPress:(NSString*)identifier;

@end


@interface ZAFHotKeyManager : NSObject

- (void)setHotKeyListener:(id<ZAFHotKeyListener>)listener;

- (BOOL)registerHotKey:(ZAFHotKey*)hotKey withIdentifier:(NSString*)identifier;
- (BOOL)unregisterHotKeyWithIdentifier:(NSString*)identifier;
- (void)unregisterAllHotKeys;

- (BOOL)isExistentHotKeyWithIdentifier:(NSString*)identifier;

@end
