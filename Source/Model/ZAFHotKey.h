#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


@interface ZAFHotKey : NSObject <NSCopying, NSMutableCopying>

+ (ZAFHotKey*)emptyHotKey;

- (id)initWithKeyCode:(int)keyCode keyModifiers:(NSEventModifierFlags)keyModifiers;

- (int)keyCode;
- (NSEventModifierFlags)keyModifiers;

- (BOOL)isEmpty;

@end



@interface ZAFMutableHotKey : ZAFHotKey

+ (ZAFMutableHotKey*)emptyHotKey;

- (void)setKeyCode:(int)keyCode;
- (void)setKeyModifiers:(NSEventModifierFlags)keyModifiers;

@end
