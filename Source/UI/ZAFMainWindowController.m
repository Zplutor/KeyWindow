#import "ZAFMainWindowController.h"
#import "ZAFFrame.h"
#import "ZAFLayoutItem.h"
#import "ZAFLayoutItemListViewController.h"
#import "ZAFLayoutItemViewController.h"
#import "ZAFLocalization.h"
#import "ZAFPreference.h"
#import "ZAFRuntime.h"
#import "ZAFUINotifications.h"


static const NSInteger kAddLayoutItemButtonSegmentIndex = 0;
static const NSInteger kDeleteLayoutItemButtonSegmentIndex = 1;
static const NSInteger kEditLayoutItemButtonSegmentIndex = 2;


static NSString* GetApplicationVersion();


@interface ZAFMainWindowController () <NSWindowDelegate, ZAFLayoutItemListViewControllerListener> {
    
    ZAFLayoutItemListViewController* _layoutItemListViewController;
    ZAFLayoutItemViewController* _layoutItemViewController;
}

@property (nonatomic, weak) IBOutlet NSView* layoutItemListViewPlaceHolder;
@property (nonatomic, weak) IBOutlet NSView* layoutItemViewPlaceHolder;

@property (nonatomic, weak) IBOutlet NSSegmentedControl* layoutItemListViewSegmentButtons;

@property (nonatomic, weak) IBOutlet NSButton* saveLayoutItemButton;
@property (nonatomic, weak) IBOutlet NSButton* discardLayoutItemButton;

@property (nonatomic, weak) IBOutlet NSButton* showIconOnStatusBarButton;
@property (nonatomic, weak) IBOutlet NSButton* launchAtLoginButton;

@property (nonatomic, weak) IBOutlet NSTextField* versionLabel;

- (IBAction)zaf_layoutItemListViewSegmentButtonDidClick:(id)sender;
- (IBAction)saveLayoutItemButtonDidClick:(id)sender;
- (IBAction)discardLayoutItemButtonDidClick:(id)sender;
- (IBAction)zaf_showIconOnStatusBarButtonDidClick:(id)sender;
- (IBAction)zaf_launchAtLoginButtonClick:(id)sender;
- (IBAction)zaf_exitApplicationButtonDidClick:(id)sender;

- (void)zaf_addLayoutItemButtonDidClick;
- (void)zaf_deleteLayoutItemButtonDidClick;
- (void)zaf_editLayoutItemButtonDidClick;

- (void)zaf_loadSubviews;
- (void)zaf_loadData;

- (void)zaf_switchToEditingMode:(BOOL)isEditing;

@end



@implementation ZAFMainWindowController


+ (ZAFMainWindowController*)create {
    return [[ZAFMainWindowController alloc] initWithWindowNibName:@"MainWindow"];
}


- (void)windowDidLoad {
    
    [super windowDidLoad];
    [self zaf_loadSubviews];
    [self zaf_loadData];
}


- (void)zaf_loadSubviews {
    
    _layoutItemListViewController = [ZAFLayoutItemListViewController create];
    [_layoutItemListViewController setListener:self];
    [_layoutItemListViewController setSuperView:_layoutItemListViewPlaceHolder];
    
    _layoutItemViewController = [ZAFLayoutItemViewController create];
    [_layoutItemViewController setSuperView:_layoutItemViewPlaceHolder];
    
    BOOL showIconOnStatusBar = [[ZAFPreference sharedPreference] showIconOnStatusBar];
    self.showIconOnStatusBarButton.state = showIconOnStatusBar ? NSOnState : NSOffState;
    
    BOOL launchAtLogin = [[ZAFPreference sharedPreference] launchApplicationAtLogin];
    self.launchAtLoginButton.state = launchAtLogin ? NSOnState : NSOffState;
    
    self.versionLabel.stringValue = GetApplicationVersion();
}


- (void)zaf_loadData {
    
    NSArray* layoutItems = [[ZAFRuntime defaultRuntime] allLayoutItems];
    [_layoutItemListViewController addLayoutItems:layoutItems];
}


- (void)layoutItemListViewControllerDidChangeSelection:(ZAFLayoutItemListViewController*)controller {
    
    ZAFLayoutItem* selectedLayoutItem = controller.selectedLayoutItem;
    BOOL isSelected = selectedLayoutItem != nil;
    
    if (isSelected) {
        [_layoutItemViewController setLayoutItem:selectedLayoutItem];
    }
    else {
        [_layoutItemViewController setLayoutItem:[[ZAFLayoutItem alloc] init]];
    }

    [self.layoutItemListViewSegmentButtons setEnabled:isSelected forSegment:kEditLayoutItemButtonSegmentIndex];
    [self.layoutItemListViewSegmentButtons setEnabled:isSelected forSegment:kDeleteLayoutItemButtonSegmentIndex];
}


- (void)layoutItemListViewControllerDidDoubleClick:(ZAFLayoutItemListViewController*)controller {
    
    ZAFLayoutItem* selectedLayoutItem = controller.selectedLayoutItem;
    if (selectedLayoutItem != nil) {
        [self zaf_switchToEditingMode:YES];
    }
}


- (IBAction)zaf_layoutItemListViewSegmentButtonDidClick:(id)sender {
    
    NSInteger clickedSegmentIndex = self.layoutItemListViewSegmentButtons.selectedSegment;
    if (clickedSegmentIndex < 0) {
        return;
    }
    
    switch (clickedSegmentIndex) {
            
        case kAddLayoutItemButtonSegmentIndex:
            [self zaf_addLayoutItemButtonDidClick];
            break;
            
        case kDeleteLayoutItemButtonSegmentIndex:
            [self zaf_deleteLayoutItemButtonDidClick];
            break;
            
        case kEditLayoutItemButtonSegmentIndex:
            [self zaf_editLayoutItemButtonDidClick];
            break;
            
        default:
            break;
    }
}


- (void)zaf_addLayoutItemButtonDidClick {
    
    ZAFMutableLayoutItem* newLayoutItem = [[ZAFMutableLayoutItem alloc] init];
    newLayoutItem.identifier = @([[NSDate date] timeIntervalSince1970]).stringValue;
    newLayoutItem.name = ZAFGetLocalizedString(@"NewLayoutItemName");
    newLayoutItem.frame = [[ZAFFrame alloc] initWithXPercent:0.25
                                                    yPercent:0.25
                                                widthPercent:0.5
                                               heightPercent:0.5];
    
    [_layoutItemListViewController addLayoutItem:newLayoutItem];
    [_layoutItemListViewController selectLayoutItemWithIdentifier:newLayoutItem.identifier];
    [self zaf_switchToEditingMode:YES];
}


- (void)zaf_deleteLayoutItemButtonDidClick {
    
    ZAFLayoutItem* selectedLayoutItem = [_layoutItemListViewController selectedLayoutItem];
    if (selectedLayoutItem == nil) {
        return;
    }
    
    NSAlert* deleteAlert = [[NSAlert alloc] init];
    [deleteAlert addButtonWithTitle:ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertOkButtonText")];
    [deleteAlert addButtonWithTitle:ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertCancelButtonText")];
    deleteAlert.messageText = [NSString stringWithFormat:
                               ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertTitle"),
                               selectedLayoutItem.name];
    
    [deleteAlert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode != NSAlertFirstButtonReturn) {
            return;
        }
        
        BOOL isSucceeded = [[ZAFRuntime defaultRuntime] deleteLayoutItem:selectedLayoutItem];
        if (isSucceeded) {
            
            [_layoutItemListViewController deleteSelectedLayoutItem];
        }
    }];
}


- (void)zaf_editLayoutItemButtonDidClick {
    
    [self zaf_switchToEditingMode:YES];
}


- (IBAction)saveLayoutItemButtonDidClick:(id)sender {
    
    ZAFLayoutItem* editingLayoutItem = [_layoutItemViewController layoutItem];
    ZAFLayoutItem* existedLayoutItem = [[ZAFRuntime defaultRuntime] layoutItemWithIdentifier:editingLayoutItem.identifier];
    
    if (existedLayoutItem == nil) {
        
        BOOL addSucceeded = [[ZAFRuntime defaultRuntime] addLayoutItem:editingLayoutItem];
            
        if (addSucceeded) {
            [_layoutItemListViewController updateSelectedLayoutItemWithNewLayoutItem:editingLayoutItem];
        }
        else {
            [_layoutItemListViewController deleteSelectedLayoutItem];
        }
    }
    else {
        
        [[ZAFRuntime defaultRuntime] updateLayoutItem:editingLayoutItem];
        [_layoutItemListViewController updateSelectedLayoutItemWithNewLayoutItem:editingLayoutItem];
    }
    
    [self zaf_switchToEditingMode:NO];
}


- (IBAction)discardLayoutItemButtonDidClick:(id)sender {
    
    ZAFLayoutItem* selectedLayoutItem = [_layoutItemListViewController selectedLayoutItem];
    ZAFLayoutItem* existedLayoutItem = [[ZAFRuntime defaultRuntime] layoutItemWithIdentifier:selectedLayoutItem.identifier];
    
    if (existedLayoutItem == nil) {
        [_layoutItemListViewController deleteSelectedLayoutItem];
    }
    else {
        [_layoutItemViewController setLayoutItem:existedLayoutItem];
    }
    
    [self zaf_switchToEditingMode:NO];
}


- (void)zaf_switchToEditingMode:(BOOL)isEditing {
 
    [_layoutItemListViewController setEnabled:! isEditing];
    [_layoutItemViewController setEditable:isEditing];
    
    BOOL canEnableModifyButtongs = (! isEditing) && _layoutItemListViewController.hasSelection;
    
    [self.layoutItemListViewSegmentButtons setEnabled:! isEditing forSegment:kAddLayoutItemButtonSegmentIndex];
    [self.layoutItemListViewSegmentButtons setEnabled:canEnableModifyButtongs
                                           forSegment:kDeleteLayoutItemButtonSegmentIndex];
    [self.layoutItemListViewSegmentButtons setEnabled:canEnableModifyButtongs
                                           forSegment:kEditLayoutItemButtonSegmentIndex];
    
    self.saveLayoutItemButton.hidden = ! isEditing;
    self.discardLayoutItemButton.hidden = ! isEditing;
    
    if (isEditing) {
        [_layoutItemViewController focus];
    }
    else {
        [_layoutItemListViewController focus];
    }
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
