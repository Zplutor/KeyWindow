#import "ZAFLayoutItemListViewController.h"
#import "ZAFLayoutItem.h"
#import "ZAFLocalization.h"


static const NSTableViewAnimationOptions kTableViewAnimation = NSTableViewAnimationEffectNone;


@interface ZAFLayoutItemListViewController () <NSTableViewDelegate, NSTableViewDataSource> {

    __weak id<ZAFLayoutItemListViewControllerListener> _listener;
    NSMutableArray* _layoutItems;
}

@property (nonatomic, weak) IBOutlet NSTableView* layoutItemTableView;

- (NSUInteger)zaf_indexOfLayoutItemWithIdentifier:(NSString*)identifier;
- (void)zaf_layoutItemTableViewDidDoubleClick:(id)sender;

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
}


- (void)setSuperView:(NSView*)superView {
    
    [self.view setFrameSize:superView.frame.size];
    [superView addSubview:self.view];
}


- (void)focus {
    
    [self.view.window makeFirstResponder:self.view];
}


- (void)setListener:(id<ZAFLayoutItemListViewControllerListener>)listener {
    
    _listener = listener;
}


- (void)addLayoutItems:(NSArray*)layoutItems {
    
    NSParameterAssert(layoutItems != nil);
    
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
    
    //自动选择下一个项
    if (_layoutItems.count == 0) {
        return;
    }
    
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
    [self.layoutItemTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:selectedIndex]
                                        columnIndexes:[NSIndexSet indexSetWithIndex:0]];
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

    NSTableCellView* cellView = [tableView makeViewWithIdentifier:@"LayoutItem" owner:self];
    cellView.textField.backgroundColor = [NSColor clearColor];
    cellView.textField.stringValue =
        layoutItem.name.length == 0 ? ZAFGetLocalizedString(@"EmptyLayoutItemNameDisplayText") : layoutItem.name;
    cellView.textField.enabled = tableView.isEnabled;
    return cellView;
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
