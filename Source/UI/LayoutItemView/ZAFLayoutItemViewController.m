#import "ZAFLayoutItemViewController.h"
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "ZAFFrame.h"
#import "ZAFHotKey.h"
#import "ZAFLayoutItem.h"
#import "ZAFWindowLayoutView.h"


static int IntegerValueFromPercentValue(double percentValue);
static double PercentValueFromIntegerValue(int integerValue);


@interface ZAFLayoutItemViewController () <ZAFWindowLayoutViewDelegate> {
    
    ZAFWindowLayoutView* _windowLayoutView;
    NSString* _layoutItemIdentifier;
}

@property (nonatomic, weak) IBOutlet NSTextField* nameTextField;
@property (nonatomic, weak) IBOutlet SRRecorderControl* hotKeyRecorder;
@property (nonatomic, weak) IBOutlet NSTextField* xPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* yPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* widthPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* heightPercentTextField;
@property (nonatomic, weak) IBOutlet NSNumberFormatter* integerNumberFormatter;
@property (nonatomic, weak) IBOutlet NSView* windowLayoutViewPlaceHolder;

- (IBAction)textFieldDidChanged:(id)sender;

@end



@implementation ZAFLayoutItemViewController


+ (ZAFLayoutItemViewController*)create {
    
    return [[ZAFLayoutItemViewController alloc] initWithNibName:@"LayoutItemView" bundle:[NSBundle mainBundle]];
}


- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
        _layoutItemIdentifier = [NSString string];
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.hotKeyRecorder setAllowedModifierFlags:NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask
                           requiredModifierFlags:0
                        allowsEmptyModifierFlags:NO];
    
    self.integerNumberFormatter.allowsFloats = NO;
    
    _windowLayoutView = [[ZAFWindowLayoutView alloc] initWithFrame:self.windowLayoutViewPlaceHolder.bounds];
    _windowLayoutView.delegate = self;
    _windowLayoutView.enabled = NO;
    [self.windowLayoutViewPlaceHolder addSubview:_windowLayoutView];
}


- (void)setSuperView:(NSView*)superView {
    
    [self.view setFrameSize:superView.frame.size];
    [superView addSubview:self.view];
}


- (void)focus {
    
    [self.view.window makeFirstResponder:self.nameTextField];
}


- (void)setEditable:(BOOL)isEditable {
    
    self.nameTextField.enabled = isEditable;
    self.hotKeyRecorder.enabled = isEditable;
    self.xPercentTextField.enabled = isEditable;
    self.yPercentTextField.enabled = isEditable;
    self.widthPercentTextField.enabled = isEditable;
    self.heightPercentTextField.enabled = isEditable;
    _windowLayoutView.enabled = isEditable;
}


- (ZAFLayoutItem*)layoutItem {
    
    ZAFMutableLayoutItem* layoutItem = [[ZAFMutableLayoutItem alloc] init];
    
    layoutItem.identifier = _layoutItemIdentifier;
    layoutItem.name = self.nameTextField.stringValue;
    
    NSDictionary* hotKeyRecorderValues = self.hotKeyRecorder.objectValue;
    NSNumber* keyCodeNumber = [hotKeyRecorderValues objectForKey:SRShortcutKeyCode];
    NSNumber* keyModifiersNumber = [hotKeyRecorderValues objectForKey:SRShortcutModifierFlagsKey];
    if ( (keyCodeNumber != nil) && (keyModifiersNumber != nil) ) {
        layoutItem.hotKey = [[ZAFHotKey alloc] initWithKeyCode:keyCodeNumber.intValue
                                                  keyModifiers:keyModifiersNumber.unsignedIntegerValue];
    }
    
    ZAFMutableFrame* frame = [[ZAFMutableFrame alloc] init];
    frame.xPercent = PercentValueFromIntegerValue(self.xPercentTextField.intValue);
    frame.yPercent = PercentValueFromIntegerValue(self.yPercentTextField.intValue);
    frame.widthPercent = PercentValueFromIntegerValue(self.widthPercentTextField.intValue);
    frame.heightPercent = PercentValueFromIntegerValue(self.heightPercentTextField.intValue);
    layoutItem.frame = frame;
    
    return layoutItem;
}


- (void)setLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    _layoutItemIdentifier = layoutItem.identifier;
    
    self.nameTextField.stringValue = layoutItem.name;
    
    ZAFHotKey* hotKey = layoutItem.hotKey;
    self.hotKeyRecorder.objectValue = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @(hotKey.keyCode),
                                       SRShortcutKeyCode,
                                       @(hotKey.keyModifiers),
                                       SRShortcutModifierFlagsKey,
                                       nil];

    ZAFFrame* frame = layoutItem.frame;
    self.xPercentTextField.intValue = IntegerValueFromPercentValue(frame.xPercent);
    self.yPercentTextField.intValue = IntegerValueFromPercentValue(frame.yPercent);
    self.widthPercentTextField.intValue = IntegerValueFromPercentValue(frame.widthPercent);
    self.heightPercentTextField.intValue = IntegerValueFromPercentValue(frame.heightPercent);
    
    [_windowLayoutView changeWithXPercent:frame.xPercent
                                 yPercent:frame.yPercent
                             widthPercent:frame.widthPercent
                            heightPercent:frame.heightPercent];
}


- (void)windowLayoutDidChangeToXPercent:(double)xPercent
                               yPercent:(double)yPercent
                           widthPercent:(double)widthPercent
                          heightPercent:(double)heightPercent {
    
    self.xPercentTextField.intValue = IntegerValueFromPercentValue(xPercent);
    self.yPercentTextField.intValue = IntegerValueFromPercentValue(yPercent);
    self.widthPercentTextField.intValue = IntegerValueFromPercentValue(widthPercent);
    self.heightPercentTextField.intValue = IntegerValueFromPercentValue(heightPercent);
}


- (void)windowLayoutDidClear {
    
    self.xPercentTextField.stringValue = [NSString string];
    self.yPercentTextField.stringValue = [NSString string];
    self.widthPercentTextField.stringValue = [NSString string];
    self.heightPercentTextField.stringValue = [NSString string];
}


- (IBAction)textFieldDidChanged:(id)sender {
    
    if (sender == self.xPercentTextField) {
        _windowLayoutView.xPercent = PercentValueFromIntegerValue(self.xPercentTextField.intValue);
    }
    else if (sender == self.yPercentTextField) {
        _windowLayoutView.yPercent = PercentValueFromIntegerValue(self.yPercentTextField.intValue);
    }
    else if (sender == self.widthPercentTextField) {
        _windowLayoutView.widthPercent = PercentValueFromIntegerValue(self.widthPercentTextField.intValue);
    }
    else if (sender == self.heightPercentTextField) {
        _windowLayoutView.heightPercent = PercentValueFromIntegerValue(self.heightPercentTextField.intValue);
    }
}


@end



static int IntegerValueFromPercentValue(double percentValue) {
    
    if (percentValue < 0) {
        return 0;
    }
    else if (percentValue > 1) {
        return 1;
    }
    else {
        return percentValue * 100;
    }
}


static double PercentValueFromIntegerValue(int integerValue) {
    
    if (integerValue < 0) {
        return 0;
    }
    else if (integerValue > 100) {
        return 100;
    }
    else {
        return (double)integerValue / 100;
    }
}

