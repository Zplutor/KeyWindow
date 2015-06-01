#import "ZAFLayoutsPageViewController.h"
#import "ZAFEditLayoutItemSheetWindowController.h"
#import "ZAFFrame.h"
#import "ZAFLayoutItem.h"
#import "ZAFLayoutItemListViewController.h"
#import "ZAFLocalization.h"
#import "ZAFRuntime.h"


static const NSInteger kAddLayoutItemSegmentButtonIndex = 0;
static const NSInteger kDeleteLayoutItemSegmentButtonIndex = 1;
static const NSInteger kEditLayoutItemSegmentButtonIndex = 2;


@interface ZAFLayoutsPageViewController () <
    ZAFLayoutItemListViewControllerListener,
    ZAFEditLayoutItemSheetWindowControllerDelegate> {
    
    ZAFLayoutItemListViewController* _layoutItemListViewController;
    ZAFEditLayoutItemSheetWindowController* _editLayoutItemSheetWindowController;
}

@property (nonatomic, weak) IBOutlet NSView* layoutItemListViewPlaceHolder;
@property (nonatomic, weak) IBOutlet NSSegmentedControl* layoutItemListViewSegmentButtons;

- (IBAction)zaf_layoutItemListViewSegmentButtonDidClick:(id)sender;
- (void)zaf_addLayoutItemButtonDidClick;
- (void)zaf_deleteLayoutItemButtonDidClick;
- (void)zaf_editLayoutItemButtonDidClick;

- (void)zaf_showFailedAlertWithTitle:(NSString*)title;

@end



@implementation ZAFLayoutsPageViewController


+ (ZAFLayoutsPageViewController*)create {
    
    return [[ZAFLayoutsPageViewController alloc] initWithNibName:@"LayoutsPageView" bundle:[NSBundle mainBundle]];
}


- (void)setSuperView:(NSView*)superView {
    
    self.view.frame = superView.bounds;
    [superView addSubview:self.view];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _layoutItemListViewController = [ZAFLayoutItemListViewController create];
    [_layoutItemListViewController setListener:self];
    [_layoutItemListViewController setSuperView:_layoutItemListViewPlaceHolder];
    
    _editLayoutItemSheetWindowController = [ZAFEditLayoutItemSheetWindowController create];
    [_editLayoutItemSheetWindowController setDelegate:self];
    
    NSArray* layoutItems = [[ZAFRuntime defaultRuntime] allLayoutItems];
    [_layoutItemListViewController addLayoutItems:layoutItems];
}


- (IBAction)zaf_layoutItemListViewSegmentButtonDidClick:(id)sender {
    
    NSInteger clickedSegmentIndex = self.layoutItemListViewSegmentButtons.selectedSegment;
    
    switch (clickedSegmentIndex) {
            
        case kAddLayoutItemSegmentButtonIndex:
            [self zaf_addLayoutItemButtonDidClick];
            break;
            
        case kDeleteLayoutItemSegmentButtonIndex:
            [self zaf_deleteLayoutItemButtonDidClick];
            break;
            
        case kEditLayoutItemSegmentButtonIndex:
            [self zaf_editLayoutItemButtonDidClick];
            break;
            
        default:
            break;
    }
}


- (void)zaf_addLayoutItemButtonDidClick {
 
    ZAFMutableLayoutItem* newLayoutItem = [[ZAFMutableLayoutItem alloc] init];
    newLayoutItem.identifier = @([[NSDate date] timeIntervalSince1970]).stringValue;
    newLayoutItem.frame = [[ZAFFrame alloc] initWithXPercent:0
                                                    yPercent:0
                                                widthPercent:0.5
                                               heightPercent:0.5];
    
    [_editLayoutItemSheetWindowController setLayoutItem:newLayoutItem];
    [self.view.window beginSheet:_editLayoutItemSheetWindowController.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode != NSModalResponseOK) {
            return;
        }
        
        ZAFLayoutItem* newItem = _editLayoutItemSheetWindowController.layoutItem;
        BOOL isSucceeded = [[ZAFRuntime defaultRuntime] addLayoutItem:newItem];
            
        if (isSucceeded) {
            
            [_layoutItemListViewController addLayoutItem:newItem];
            [_layoutItemListViewController selectLayoutItemWithIdentifier:newItem.identifier];
        }
        else {
            [self zaf_showFailedAlertWithTitle:ZAFGetLocalizedString(@"AddLayoutItemFailedAlertTitle")];
        }
    }];
}


- (void)zaf_deleteLayoutItemButtonDidClick {
    
    ZAFLayoutItem* selectedLayoutItem = [_layoutItemListViewController selectedLayoutItem];
    if (selectedLayoutItem == nil) {
        return;
    }
    
    NSAlert* deleteAlert = [[NSAlert alloc] init];
    [deleteAlert addButtonWithTitle:ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertOkButtonText")];
    [deleteAlert addButtonWithTitle:ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertCancelButtonText")];
    deleteAlert.messageText = ZAFGetLocalizedString(@"ConfirmDeleteLayoutItemAlertTitle");
    
    [deleteAlert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode != NSAlertFirstButtonReturn) {
            return;
        }
        
        BOOL isSucceeded = [[ZAFRuntime defaultRuntime] deleteLayoutItem:selectedLayoutItem];
        
        if (isSucceeded) {
            [_layoutItemListViewController deleteSelectedLayoutItem];
        }
        else {
            [self zaf_showFailedAlertWithTitle:ZAFGetLocalizedString(@"DeleteLayoutItemFailedAlertTitle")];
        }
    }];
}


- (void)zaf_editLayoutItemButtonDidClick {
    
    ZAFLayoutItem* selectedLayoutItem = [_layoutItemListViewController selectedLayoutItem];
    if (selectedLayoutItem == nil) {
        return;
    }
    
    [_editLayoutItemSheetWindowController setLayoutItem:selectedLayoutItem];
    [self.view.window beginSheet:_editLayoutItemSheetWindowController.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode != NSModalResponseOK) {
            return;
        }
        
        ZAFLayoutItem* newItem = _editLayoutItemSheetWindowController.layoutItem;
        BOOL isSucceeded = [[ZAFRuntime defaultRuntime] updateLayoutItem:newItem];
        
        if (isSucceeded) {
            [_layoutItemListViewController updateSelectedLayoutItemWithNewLayoutItem:newItem];
        }
        else {
            [self zaf_showFailedAlertWithTitle:ZAFGetLocalizedString(@"EditLayoutItemFailedAlertTitle")];
        }
    }];
}


- (void)zaf_showFailedAlertWithTitle:(NSString*)title {
 
    NSAlert* alert = [[NSAlert alloc] init];
    alert.alertStyle = NSWarningAlertStyle;
    alert.messageText = title;
    alert.informativeText = ZAFGetLocalizedString(@"OperateLayoutItemFailedAlertMessage");
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}


- (void)layoutItemListViewControllerDidChangeSelection:(ZAFLayoutItemListViewController*)controller {
    
    BOOL hasSelection = [_layoutItemListViewController selectedLayoutItem] != nil;
    
    [_layoutItemListViewSegmentButtons setEnabled:hasSelection forSegment:kDeleteLayoutItemSegmentButtonIndex];
    [_layoutItemListViewSegmentButtons setEnabled:hasSelection forSegment:kEditLayoutItemSegmentButtonIndex];
}


- (void)layoutItemListViewControllerDidDoubleClick:(ZAFLayoutItemListViewController*)controller {
    
    [self zaf_editLayoutItemButtonDidClick];
}


- (void)editLayoutItemSheetWindowControllerDidFinishEditing {

    [self.view.window endSheet:_editLayoutItemSheetWindowController.window returnCode:NSModalResponseOK];
}


- (void)editLayoutItemSheetWindowControllerDidCancelEditing {

    [self.view.window endSheet:_editLayoutItemSheetWindowController.window returnCode:NSModalResponseCancel];
}


@end
