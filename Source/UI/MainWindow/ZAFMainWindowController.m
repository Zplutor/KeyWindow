#import "ZAFMainWindowController.h"
#import "ZAFAboutPageViewController.h"
#import "ZAFAxService.h"
#import "ZAFFrame.h"
#import "ZAFLayoutItem.h"
#import "ZAFLayoutsPageViewController.h"
#import "ZAFLocalization.h"
#import "ZAFOptionsPageViewController.h"
#import "ZAFPreference.h"
#import "ZAFPromptTrustSheetWindowController.h"
#import "ZAFRuntime.h"
#import "ZAFUINotifications.h"


@interface ZAFMainWindowController () <NSWindowDelegate, ZAFPromptTrustSheetWindowControllerDelegate> {
    
    ZAFPromptTrustSheetWindowController* _promptTrustSheetWindowController;
    BOOL _isPromptingTrust;
    
    ZAFLayoutsPageViewController* _layoutsPageViewController;
    ZAFOptionsPageViewController* _optionsPageViewController;
    ZAFAboutPageViewController* _aboutPageViewController;
}

@property (nonatomic, weak) IBOutlet NSToolbar* toolbar;
@property (nonatomic, weak) IBOutlet NSView* pagePlaceHolder;

- (IBAction)layoutsToolbarItemDidClick:(id)sender;
- (IBAction)optionsToolbarItemDidClick:(id)sender;
- (IBAction)aboutToolbarItemDidClick:(id)sender;
- (IBAction)zaf_hideWindowButtonDidClick:(id)sender;
- (IBAction)zaf_exitApplicationButtonDidClick:(id)sender;

- (void)zaf_promptTrust;
- (void)zaf_switchToPageController:(NSViewController*)controller;
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


- (void)windowDidBecomeKey:(NSNotification*)notification {
    
    if ([[ZAFPreference sharedPreference] hasPromptedForTrusting]) {
        return;
    }
    
    if (! [ZAFAxService isCurrentApplicationTrusted]) {
    
        _promptTrustSheetWindowController = [ZAFPromptTrustSheetWindowController create];
        _promptTrustSheetWindowController.delegate = self;
        
        _isPromptingTrust = YES;
        
        [self.window beginSheet:_promptTrustSheetWindowController.window
              completionHandler:^(NSModalResponse returnCode) {
                  
                  _promptTrustSheetWindowController = nil;
              }
         ];
    }
    
    [[ZAFPreference sharedPreference] setHasPromptedForTrusting:YES];
}


- (void)promptTrustSheetWindowDidClose {
    
    [self.window endSheet:_promptTrustSheetWindowController.window returnCode:NSModalResponseOK];
}


- (void)windowDidEndSheet:(NSNotification*)notification {
    
    if (_isPromptingTrust) {
        [self performSelector:@selector(zaf_promptTrust) withObject:nil afterDelay:0.1];
        _isPromptingTrust = NO;
    }
}


- (void)zaf_promptTrust {
    
    [ZAFAxService promptForTrustingCurrentApplicationIfNot];
}


- (void)zaf_loadSubviews {
    
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
    
    [self zaf_switchToPageController:_layoutsPageViewController];
}


- (IBAction)optionsToolbarItemDidClick:(id)sender {
    
    if (_optionsPageViewController == nil) {
        _optionsPageViewController = [ZAFOptionsPageViewController create];
    }
    
    [self zaf_switchToPageController:_optionsPageViewController];
}


- (IBAction)aboutToolbarItemDidClick:(id)sender {
    
    if (_aboutPageViewController == nil) {
        _aboutPageViewController = [ZAFAboutPageViewController create];
    }
    
    [self zaf_switchToPageController:_aboutPageViewController];
}


- (void)zaf_switchToPageController:(NSViewController*)controller {
    
    NSView* pageView = controller.view;
    pageView.frame = self.pagePlaceHolder.bounds;
    
    [self.pagePlaceHolder setSubviews:@[pageView]];
}



- (void)windowWillClose:(NSNotification*)notification {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZAFMainWindowDidCloseNotification object:self];
}


- (IBAction)zaf_hideWindowButtonDidClick:(id)sender {
    
    [self close];
}


- (IBAction)zaf_exitApplicationButtonDidClick:(id)sender {
    
    [[NSApplication sharedApplication] terminate:self];
}


@end



