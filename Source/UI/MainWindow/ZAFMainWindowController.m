#import "ZAFMainWindowController.h"
#import "ZAFFrame.h"
#import "ZAFLayoutItem.h"
#import "ZAFLayoutsPageViewController.h"
#import "ZAFLocalization.h"
#import "ZAFPreference.h"
#import "ZAFRuntime.h"
#import "ZAFUINotifications.h"



static NSString* GetApplicationVersion();


@interface ZAFMainWindowController () <NSWindowDelegate> {
    
    ZAFLayoutsPageViewController* _layoutsPageViewController;
}

@property (nonatomic, weak) IBOutlet NSToolbar* toolbar;

@property (nonatomic, weak) IBOutlet NSView* pagePlaceHolder;

@property (nonatomic, weak) IBOutlet NSButton* showIconOnStatusBarButton;
@property (nonatomic, weak) IBOutlet NSButton* launchAtLoginButton;

@property (nonatomic, weak) IBOutlet NSTextField* versionLabel;

- (IBAction)layoutsToolbarItemDidClick:(id)sender;
- (IBAction)optionsToolbarItemDidClick:(id)sender;
- (IBAction)aboutToolbarItemDidClick:(id)sender;

- (void)switchToPageController:(NSViewController*)controller;

- (IBAction)zaf_showIconOnStatusBarButtonDidClick:(id)sender;
- (IBAction)zaf_launchAtLoginButtonClick:(id)sender;
- (IBAction)zaf_exitApplicationButtonDidClick:(id)sender;

- (void)zaf_loadSubviews;

@end



@implementation ZAFMainWindowController


+ (ZAFMainWindowController*)create {
    return [[ZAFMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
}


- (void)windowDidLoad {
    
    [super windowDidLoad];
    [self zaf_loadSubviews];
}


- (void)zaf_loadSubviews {
    
    BOOL showIconOnStatusBar = [[ZAFPreference sharedPreference] showIconOnStatusBar];
    self.showIconOnStatusBarButton.state = showIconOnStatusBar ? NSOnState : NSOffState;
    
    BOOL launchAtLogin = [[ZAFPreference sharedPreference] launchApplicationAtLogin];
    self.launchAtLoginButton.state = launchAtLogin ? NSOnState : NSOffState;
    
    self.versionLabel.stringValue = GetApplicationVersion();
    
    //首次启动，模拟点击第一个工具栏按钮。
    [self.toolbar setSelectedItemIdentifier:@"Layouts"];
    [self layoutsToolbarItemDidClick:nil];
}


- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    
    return YES;
}


- (IBAction)layoutsToolbarItemDidClick:(id)sender {
    
    if (_layoutsPageViewController == nil) {
        _layoutsPageViewController = [ZAFLayoutsPageViewController create];
    }
    
    [self switchToPageController:_layoutsPageViewController];
}


- (IBAction)optionsToolbarItemDidClick:(id)sender {
    
    
}


- (IBAction)aboutToolbarItemDidClick:(id)sender {
    
    
}


- (void)switchToPageController:(NSViewController*)controller {
    
    NSView* pageView = controller.view;
    pageView.frame = self.pagePlaceHolder.bounds;
    
    [self.pagePlaceHolder setSubviews:@[pageView]];
}



- (IBAction)zaf_showIconOnStatusBarButtonDidClick:(id)sender {
    
    BOOL isOn = self.showIconOnStatusBarButton.state == NSOnState;
    
    [[ZAFPreference sharedPreference] setShowIconOnStatusBar:isOn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZAFShowIconOnStatusBarOptionDidChangeNotification
                                                        object:self
                                                      userInfo:@{ ZAFBoolValueKey: @(isOn) }];
}


- (IBAction)zaf_launchAtLoginButtonClick:(id)sender {
    
    BOOL isOn = self.launchAtLoginButton.state == NSOnState;
    
    [[ZAFPreference sharedPreference] setLaunchApplicationAtLogin:isOn];
}


- (void)windowWillClose:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZAFMainWindowDidCloseNotification object:self];
}


- (IBAction)zaf_exitApplicationButtonDidClick:(id)sender {
    
    [[NSApplication sharedApplication] terminate:self];
}


@end



static NSString* GetApplicationVersion() {
    
    NSDictionary* bundleInformation = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [bundleInformation objectForKey:@"CFBundleShortVersionString"];
    if (version == nil) {
        return [NSString string];
    }
    return version;
}
