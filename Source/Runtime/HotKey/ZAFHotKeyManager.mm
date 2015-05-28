#import "ZAFHotKeyManager.h"
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "ZAFHotKey.h"


static int CarbonModifiersFromCocoaModifiers(NSEventModifierFlags cocoaModifiers);


@interface ZAFHotKeyManager () {

    __weak id<ZAFHotKeyListener> _listener;
}

- (void)zaf_hotKeyDidPress:(PTHotKey*)hotKey;

@end



@implementation ZAFHotKeyManager


- (void)setHotKeyListener:(id<ZAFHotKeyListener>)listener {
    
    NSParameterAssert(listener != nil);
    _listener = listener;
}


- (BOOL)registerHotKey:(ZAFHotKey*)hotKey withIdentifier:(NSString*)identifier {
    
    NSParameterAssert(hotKey != nil);
    NSParameterAssert(identifier != nil);
    
    PTKeyCombo* keyCombo = [PTKeyCombo keyComboWithKeyCode:hotKey.keyCode
                                                 modifiers:CarbonModifiersFromCocoaModifiers(hotKey.keyModifiers)];
    
    PTHotKey* ptHotKey = [[PTHotKey alloc] init];
    [ptHotKey setName:identifier];
    [ptHotKey setKeyCombo:keyCombo];
    [ptHotKey setIsExclusive:YES];
    [ptHotKey setTarget:self];
    [ptHotKey setAction:@selector(zaf_hotKeyDidPress:)];
    
    return [[PTHotKeyCenter sharedCenter] registerHotKey:ptHotKey];
}


- (BOOL)unregisterHotKeyWithIdentifier:(NSString*)identifier {
    
    NSParameterAssert(identifier != nil);
    
    [[PTHotKeyCenter sharedCenter] unregisterHotKeyForName:identifier];
    return YES;
}


- (void)unregisterAllHotKeys {
    
    NSArray* allHotKey = [[PTHotKeyCenter sharedCenter] allHotKeys];
    
    for (PTHotKey* eachHotKey in allHotKey) {
        [[PTHotKeyCenter sharedCenter] unregisterHotKey:eachHotKey];
    }
}


- (BOOL)isExistentHotKeyWithIdentifier:(NSString*)identifier {
    
    NSParameterAssert(identifier != nil);
    
    PTHotKey* hotKey = [[PTHotKeyCenter sharedCenter] hotKeyForName:identifier];
    return hotKey != nil;
}


- (void)zaf_hotKeyDidPress:(PTHotKey*)hotKey {
    
    if (_listener != nil) {
        [_listener hotKeyDidPress:hotKey.name];
    }
}


@end



static int CarbonModifiersFromCocoaModifiers(NSEventModifierFlags cocoaModifiers) {
    
    struct MapItem {
        NSEventModifierFlags cocoaModfier;
        int carbonModifier;
    };
    
    MapItem modifierMap[] = {
        { NSCommandKeyMask, cmdKey },
        { NSAlternateKeyMask, optionKey },
        { NSControlKeyMask, controlKey },
        { NSShiftKeyMask, shiftKey },
    };
    
    int carbonModifiers = 0;
    
    for (int index = 0; index < sizeof(modifierMap) / sizeof(MapItem); ++index) {
        
        if (cocoaModifiers & modifierMap[index].cocoaModfier) {
            carbonModifiers |= modifierMap[index].carbonModifier;
        }
    }
    
    return carbonModifiers;
}

