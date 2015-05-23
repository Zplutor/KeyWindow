#import "ZAFHotKey.h"


@interface ZAFHotKey () {
@protected
    int _keyCode;
    NSEventModifierFlags _keyModifiers;
}

@end



@implementation ZAFHotKey


+ (ZAFHotKey*)emptyHotKey {
    return [[ZAFHotKey alloc] init];
}


- (id)init {
    
    return [self initWithKeyCode:-1 keyModifiers:0];
}


- (id)initWithKeyCode:(int)keyCode keyModifiers:(NSEventModifierFlags)keyModifiers {
    
    self = [super init];
    if (self) {
        
        _keyCode = keyCode;
        _keyModifiers = keyModifiers;
    }
    return self;
}


- (int)keyCode {
    return _keyCode;
}


- (NSEventModifierFlags)keyModifiers {
    return _keyModifiers;
}


- (BOOL)isEmpty {
    return _keyCode < 0;
}


- (id)copyWithZone:(NSZone*)zone {
    
    return [[[self class] allocWithZone:zone] initWithKeyCode:_keyCode keyModifiers:_keyModifiers];
}


@end



@implementation ZAFMutableHotKey


+ (ZAFMutableHotKey*)emptyHotKey {
    return [[ZAFMutableHotKey alloc] init];
}


- (void)setKeyCode:(int)keyCode {
    _keyCode = keyCode;
}


- (void)setKeyModifiers:(NSEventModifierFlags)keyModifiers {
    _keyModifiers = keyModifiers;
}


- (id)mutableCopyWithZone:(NSZone*)zone {
    
    return [self copyWithZone:zone];
}


@end