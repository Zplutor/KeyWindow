#import "ZAFLayoutItemListViewController.h"
#import <ShortcutRecorder/SRKeyCodeTransformer.h>
#import <ShortcutRecorder/SRModifierFlagsTransformer.h>
#import "ZAFHotKey.h"
#import "ZAFLayoutCellView.h"
#import "ZAFLayoutItem.h"
#import "ZAFLocalization.h"
#import "ZAFRuntime.h"


static const NSTableViewAnimationOptions kTableViewAnimation = NSTableViewAnimationEffectNone;


@interface ZAFLayoutItemListViewController () <NSTableViewDelegate, NSTableViewDataSource> {

    NSTextField* _watermarkLabel;
    
    __weak id<ZAFLayoutItemListViewControllerListener> _listener;
    NSMutableArray* _layoutItems;
}

@property (nonatomic, weak) IBOutlet NSTableView* layoutItemTableView;

- (NSUInteger)zaf_indexOfLayoutItemWithIdentifier:(NSString*)identifier;
- (void)zaf_layoutItemTableViewDidDoubleClick:(id)sender;

- (void)zaf_initializeLayoutCellView:(ZAFLayoutCellView*)view forLayoutFrame:(ZAFFrame*)layoutFrame;
- (void)zaf_initializeHotKeyCellView:(NSTableCellView*)view forHotKey:(ZAFHotKey*)hotKey;
- (void)zaf_initializeIsEffectedCellView:(NSTableCellView*)view forLayoutItemIdentifier:(NSString*)identifier;

- (NSRect)zaf_watermarkLabelFrame;
- (void)zaf_showWatermarkLabel;
- (void)zaf_hideWatermarkLabel;

@end



@implementation ZAFLayoutItemListViewController


+ (ZAFLayoutItemListViewController*)create {
    
    return [[ZAFLayoutItemListViewController alloc] initWithNibName:@"LayoutItemListView" bundle:[NSBundle mainBundle]];
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _layoutItems = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.layoutItemTableView.delegate = self;
    self.layoutItemTableView.dataSource = self;
    self.layoutItemTableView.doubleAction = @selector(zaf_layoutItemTableViewDidDoubleClick:);
    
    if (_layoutItems.count == 0) {
        [self zaf_showWatermarkLabel];
    }
}


- (void)viewWillLayout {
    
    [super viewWillLayout];
    
    _watermarkLabel.frame = [self zaf_watermarkLabelFrame];
}


- (void)setSuperView:(NSView*)superView {
    
    [self.view setFrameSize:superView.frame.size];
    [superView addSubview:self.view];
}


- (void)zaf_showWatermarkLabel {
    
    if (_watermarkLabel == nil) {
        
        _watermarkLabel = [[NSTextField alloc] initWithFrame:[self zaf_watermarkLabelFrame]];
        _watermarkLabel.stringValue = ZAFGetLocalizedString(@"NoLayoutItemWatermarkLabelText");
        _watermarkLabel.editable = NO;
        _watermarkLabel.selectable = NO;
        _watermarkLabel.bordered = NO;
        _watermarkLabel.textColor = [NSColor grayColor];
        _watermarkLabel.font = [NSFont messageFontOfSize:20];
        _watermarkLabel.alignment = NSCenterTextAlignment;
    }
    
    [self.view addSubview:_watermarkLabel positioned:NSWindowAbove relativeTo:self.layoutItemTableView];
}


- (void)zaf_hideWatermarkLabel {
    
    if (_watermarkLabel != nil) {
        
        [_watermarkLabel removeFromSuperview];
        _watermarkLabel = nil;
    }
}


- (NSRect)zaf_watermarkLabelFrame {
    
    NSRect bounds = self.view.bounds;
    
    NSRect labelFrame = { 0 };
    labelFrame.size.width = bounds.size.width - 50 * 2;
    labelFrame.size.height = bounds.size.height / 2;
    labelFrame.origin.x = (bounds.size.width - labelFrame.size.width) / 2;
    labelFrame.origin.y = bounds.size.height / 2 - 50;
    
    return labelFrame;
}


- (void)setListener:(id<ZAFLayoutItemListViewControllerListener>)listener {
    
    _listener = listener;
}


- (void)addLayoutItems:(NSArray*)layoutItems {
    
    NSParameterAssert(layoutItems != nil);
    
    if (layoutItems.count == 0) {
        return;
    }
    
    [self zaf_hideWatermarkLabel];
    
    NSUInteger previousCount = _layoutItems.count;
    [_layoutItems addObjectsFromArray:layoutItems];
    
    [self.layoutItemTableView beginUpdates];
    NSIndexSet* insertIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(previousCount, layoutItems.count)];
    [self.layoutItemTableView insertRowsAtIndexes:insertIndexSet withAnimation:kTableViewAnimation];
    [self.layoutItemTableView endUpdates];
}



- (void)addLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    [self addLayoutItems:@[layoutItem]];
}


- (BOOL)hasSelection {
    return self.layoutItemTableView.selectedRow >= 0;
}


- (ZAFLayoutItem*)selectedLayoutItem {
    
    NSInteger selectedIndex = [self.layoutItemTableView selectedRow];
    if (selectedIndex < 0) {
        return nil;
    }
    
    return _layoutItems[selectedIndex];
}


- (BOOL)selectLayoutItemWithIdentifier:(NSString*)identifer {
    
    NSUInteger index = [self zaf_indexOfLayoutItemWithIdentifier:identifer];
    if (index == NSNotFound) {
        return NO;
    }
    
    [self.layoutItemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    [self.layoutItemTableView scrollRowToVisible:index];
    return YES;
}


- (void)deleteSelectedLayoutItem {
    
    NSInteger selectedIndex = [self.layoutItemTableView selectedRow];
    if (selectedIndex < 0) {
        return;
    }
    
    [_layoutItems removeObjectAtIndex:selectedIndex];
    [self.layoutItemTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:selectedIndex]
                                    withAnimation:kTableViewAnimation];
    

    if (_layoutItems.count == 0) {
        [self zaf_showWatermarkLabel];
        return;
    }

    //自动选择下一个项
    NSInteger newSelectIndex = selectedIndex;
    if (newSelectIndex == _layoutItems.count) {
        --newSelectIndex;
    }
    
    [self.layoutItemTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newSelectIndex]
                          byExtendingSelection:NO];
}


- (void)updateSelectedLayoutItemWithNewLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    NSInteger selectedIndex = [self.layoutItemTableView selectedRow];
    if (selectedIndex < 0) {
        return;
    }
    
    [_layoutItems replaceObjectAtIndex:selectedIndex withObject:layoutItem];
    
    NSRange reloadColumnIndexes = NSMakeRange(0, self.layoutItemTableView.tableColumns.count);
    [self.layoutItemTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex]
                                        columnIndexes:[NSIndexSet indexSetWithIndexesInRange:reloadColumnIndexes]];
}


- (void)setEnabled:(BOOL)isEnabled {
    
    [self.layoutItemTableView setEnabled:isEnabled];
    [self.layoutItemTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _layoutItems.count)]
                                        columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}


- (NSUInteger)zaf_indexOfLayoutItemWithIdentifier:(NSString*)identifier {
    
    NSUInteger index = [_layoutItems indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        ZAFLayoutItem* eachLayoutItem = obj;
        return [eachLayoutItem.identifier isEqualToString:identifier];
    }];
    
    return index;
}


- (void)zaf_layoutItemTableViewDidDoubleClick:(id)sender {
    
    if (_listener != nil) {
        [_listener layoutItemListViewControllerDidDoubleClick:self];
    }
}


#pragma NSTableViewDelegate


- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row {
    
    ZAFLayoutItem* layoutItem = _layoutItems[row];
    
    id cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"Layout"]) {
        [self zaf_initializeLayoutCellView:cellView forLayoutFrame:layoutItem.frame];
    }
    else if ([tableColumn.identifier isEqualToString:@"HotKey"]) {
        [self zaf_initializeHotKeyCellView:cellView forHotKey:layoutItem.hotKey];
    }
    else if ([tableColumn.identifier isEqualTo:@"IsEffected"]) {
        [self zaf_initializeIsEffectedCellView:cellView forLayoutItemIdentifier:layoutItem.identifier];
    }
    
    return cellView;
}


- (void)zaf_initializeLayoutCellView:(ZAFLayoutCellView*)cellView forLayoutFrame:(ZAFFrame*)layoutFrame {
    
    [cellView setLayoutFrame:layoutFrame];
}


- (void)zaf_initializeHotKeyCellView:(NSTableCellView*)cellView forHotKey:(ZAFHotKey*)hotKey {

    NSString* stringValue = nil;
    
    if (hotKey.isEmpty) {
        
        stringValue = ZAFGetLocalizedString(@"EmptyLayoutItemHotKeyDisplayText");
    }
    else {
        
        stringValue = [NSString stringWithFormat:
                       @"%@ %@",
                       [[SRModifierFlagsTransformer sharedTransformer] transformedValue:@(hotKey.keyModifiers)],
                       [[SRKeyCodeTransformer sharedPlainTransformer] transformedValue:@(hotKey.keyCode)
                                                             withImplicitModifierFlags:nil
                                                                 explicitModifierFlags:@(hotKey.keyModifiers)]];
    }
    
    cellView.textField.stringValue = stringValue;
}


- (void)zaf_initializeIsEffectedCellView:(NSTableCellView*)view forLayoutItemIdentifier:(NSString*)identifier {
    
    BOOL isEffected = [[ZAFRuntime defaultRuntime] isEffectedLayoutItemWithIdentifier:identifier];
    
    if (isEffected) {
        view.imageView.image = nil;
    }
    else {
        view.imageView.image = [NSImage imageNamed:NSImageNameCaution];
    }
}


- (void)tableViewSelectionDidChange:(NSNotification*)notification {
    
    if (_listener != nil) {
        [_listener layoutItemListViewControllerDidChangeSelection:self];
    }
}


#pragma NSTableViewDataSource


- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView {
    
    return _layoutItems.count;
}


@end
