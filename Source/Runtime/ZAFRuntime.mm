#import "ZAFRuntime.h"
#import <Carbon/Carbon.h>
#import "ZAFEvents.h"
#import "ZAFHotKeyManager.h"
#import "ZAFLayoutItem.h"
#import "ZAFLayoutItemStorage.h"
#import "ZAFWindowManager.h"


@interface ZAFRuntime () <ZAFHotKeyListener> {

    BOOL _isStarted;
    ZAFHotKeyManager* _hotKeyManager;
    ZAFWindowManager* _windowManager;
    ZAFLayoutItemStorage* _layoutItemStorage;
}

- (void)zaf_assertHasStarted;
- (void)zaf_startAllLayoutItems;

@end



@implementation ZAFRuntime


+ (ZAFRuntime*)defaultRuntime {
    
    static ZAFRuntime* instance = [[ZAFRuntime alloc] init];
    return instance;
}


- (id)init {
    
    self = [super init];
    if (self) {
        
        _isStarted = NO;
    }
    return self;
}


- (void)start {
    
    _hotKeyManager = [[ZAFHotKeyManager alloc] init];
    [_hotKeyManager setHotKeyListener:self];
    _windowManager = [[ZAFWindowManager alloc] init];
    _layoutItemStorage = [[ZAFLayoutItemStorage alloc] init];
    
    [self zaf_startAllLayoutItems];
    
    _isStarted = YES;
}


- (void)zaf_startAllLayoutItems {
    
    NSArray* layoutItems = [_layoutItemStorage allLayoutItems];
    
    for (ZAFLayoutItem* eachLayoutItem in layoutItems) {
        [_hotKeyManager registerHotKey:eachLayoutItem.hotKey withIdentifier:eachLayoutItem.identifier];
    }
}


- (void)terminate {
    
    [self zaf_assertHasStarted];
    
    [_hotKeyManager unregisterAllHotKeys];
    _hotKeyManager = nil;
    _windowManager = nil;
    _layoutItemStorage = nil;
    
    _isStarted = NO;
}


- (void)zaf_assertHasStarted {
    NSAssert(_isStarted, @"Runtime is not started yet.");
}


- (NSArray*)allLayoutItems {

    [self zaf_assertHasStarted];
    return [_layoutItemStorage allLayoutItems];
}


- (ZAFLayoutItem*)layoutItemWithIdentifier:(NSString*)identifier {
    
    [self zaf_assertHasStarted];
    return [_layoutItemStorage layoutItemWithIdentifier:identifier];
}


- (BOOL)addLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    [self zaf_assertHasStarted];
    
    if (! [_layoutItemStorage addLayoutItem:layoutItem]) {
        return NO;
    }
    
    [_hotKeyManager registerHotKey:layoutItem.hotKey withIdentifier:layoutItem.identifier];
    return YES;
}


- (BOOL)updateLayoutItem:(ZAFLayoutItem*)layoutItem {
 
    NSParameterAssert(layoutItem != nil);

    [self zaf_assertHasStarted];
    
    if (! [_layoutItemStorage updateLayoutItem:layoutItem]) {
        return NO;
    }
    
    [_hotKeyManager unregisterHotKeyWithIdentifier:layoutItem.identifier];
    [_hotKeyManager registerHotKey:layoutItem.hotKey withIdentifier:layoutItem.identifier];
    return YES;
}


- (BOOL)deleteLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    [self zaf_assertHasStarted];
    
    if (! [_layoutItemStorage deleteLayoutItemWithIdentifier:layoutItem.identifier]) {
        return NO;
    }
    
    [_hotKeyManager unregisterHotKeyWithIdentifier:layoutItem.identifier];
    return YES;
}


- (BOOL)isEffectedLayoutItemWithIdentifier:(NSString*)identifier {
    
    NSParameterAssert(identifier != nil);
    
    return [_hotKeyManager isExistentHotKeyWithIdentifier:identifier];
}


- (void)hotKeyDidPress:(NSString*)identifier {
 
    ZAFLayoutItem* layoutItem = [_layoutItemStorage layoutItemWithIdentifier:identifier];
    if (layoutItem == nil) {
        return;
    }
    
    [_windowManager moveAndResizeFocusedWindowWithFrame:layoutItem.frame];
}


@end
