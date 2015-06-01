#import "ZAFApplicationDelegate.h"
#import "ZAFAxService.h"
#import "ZAFMainWindowController.h"
#import "ZAFPreference.h"
#import "ZAFRuntime.h"
#import "ZAFUINotifications.h"
#import "ZAFUserNotificationManager.h"


@interface ZAFApplicationDelegate () {
 
    NSStatusItem* _statusItem;
    ZAFMainWindowController* _mainWindowController;
    ZAFUserNotificationManager* _userNotificationManager;
}

- (void)zaf_mainWindowDidClose:(NSNotification*)notificaiton;
- (void)zaf_showIconOnStatusBarOptionDidChange:(NSNotification*)notification;

- (void)zaf_showStatusItem;
- (void)zaf_hideStatusItem;
- (void)zaf_statusBarButtonDidClick:(NSStatusBarButton*)button;

- (void)zaf_showMainWindow;

@end



@implementation ZAFApplicationDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [[ZAFRuntime defaultRuntime] start];
    
    _userNotificationManager = [[ZAFUserNotificationManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zaf_showIconOnStatusBarOptionDidChange:)
                                                 name:ZAFShowIconOnStatusBarOptionDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zaf_mainWindowDidClose:)
                                                 name:ZAFMainWindowDidCloseNotification
                                               object:nil];
    
    if ([[ZAFPreference sharedPreference] showIconOnStatusBar]) {
        [self zaf_showStatusItem];
    }
    
    if (! [[ZAFPreference sharedPreference] hasPromptedForTrusting]) {
        [ZAFAxService promptForTrustingCurrentApplicationIfNot];
        [[ZAFPreference sharedPreference] setHasPromptedForTrusting:YES];
    }
}


- (void)applicationDidBecomeActive:(NSNotification*)notification {
    
    [self zaf_showMainWindow];
}


- (void)zaf_showIconOnStatusBarOptionDidChange:(NSNotification*)notification {
    
    NSNumber* isOn = notification.userInfo[ZAFBoolValueKey];
    
    if (isOn.boolValue) {
        [self zaf_showStatusItem];
    }
    else {
        [self zaf_hideStatusItem];
    }
}


- (void)zaf_showStatusItem {

    if (_statusItem != nil) {
        return;
    }
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    NSStatusBarButton* button = _statusItem.button;
    button.image = [NSImage imageNamed:@"StatusIcon"];
    button.target = self;
    button.action = @selector(zaf_statusBarButtonDidClick:);
}


- (void)zaf_statusBarButtonDidClick:(NSStatusBarButton*)button {
 
    [self zaf_showMainWindow];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}


- (void)zaf_showMainWindow {
    
    if (_mainWindowController == nil) {
        _mainWindowController = [ZAFMainWindowController create];
    }
    
    [_mainWindowController.window makeKeyAndOrderFront:self];
}


- (void)zaf_hideStatusItem {
    
    if (_statusItem == nil) {
        return;
    }
    
    [[NSStatusBar systemStatusBar] removeStatusItem:_statusItem];
    _statusItem = nil;
}


- (void)zaf_mainWindowDidClose:(NSNotification*)notificaiton {
    
    _mainWindowController = nil;
}


- (void)applicationWillTerminate:(NSNotification*)notification {
    
    [self zaf_hideStatusItem];
    
    _userNotificationManager = nil;
    
    [[ZAFRuntime defaultRuntime] terminate];
}


@end
