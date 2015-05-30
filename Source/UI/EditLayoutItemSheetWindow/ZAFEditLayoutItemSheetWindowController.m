#import "ZAFEditLayoutItemSheetWindowController.h"
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "ZAFFrame.h"
#import "ZAFHotKey.h"
#import "ZAFLayoutItem.h"
#import "ZAFWindowLayoutView.h"


static int IntegerValueFromPercentValue(double percentValue);
static double PercentValueFromIntegerValue(int integerValue);


static const double kMinWidthPercent = 0.2;
static const double kMinHeightPercent = 0.2;


@interface ZAFEditLayoutItemSheetWindowController () <ZAFWindowLayoutViewDelegate, SRRecorderControlDelegate> {
    
    ZAFWindowLayoutView* _windowLayoutView;
    ZAFMutableLayoutItem* _layoutItem;
}

@property (nonatomic, weak) IBOutlet NSTextField* nameTextField;
@property (nonatomic, weak) IBOutlet SRRecorderControl* hotKeyRecorder;
@property (nonatomic, weak) IBOutlet NSTextField* xPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* yPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* widthPercentTextField;
@property (nonatomic, weak) IBOutlet NSTextField* heightPercentTextField;
@property (nonatomic, weak) IBOutlet NSNumberFormatter* integerNumberFormatter;
@property (nonatomic, weak) IBOutlet NSView* windowLayoutViewPlaceHolder;

- (void)zaf_showLayoutItem;

- (IBAction)nameTextFieldDidChange:(id)sender;
- (IBAction)xTextFieldDidChange:(id)sender;
- (IBAction)yTextFieldDidChange:(id)sender;
- (IBAction)widthTextFieldDidChange:(id)sender;
- (IBAction)heightTextFieldDidChange:(id)sender;

- (IBAction)okButtonDidClick:(id)sender;
- (IBAction)cancelButtonDidClick:(id)sender;

@end



@implementation ZAFEditLayoutItemSheetWindowController


+ (ZAFEditLayoutItemSheetWindowController*)create {
    
    return [[ZAFEditLayoutItemSheetWindowController alloc] initWithWindowNibName:@"EditLayoutItemSheetWindow"];
}


- (id)initWithWindowNibName:(NSString*)nibNameOrNil {
    
    self = [super initWithWindowNibName:nibNameOrNil];
    if (self) {
     
        _layoutItem = [[ZAFLayoutItem emptyLayoutItem] mutableCopy];
    }
    return self;
}


- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    [self.hotKeyRecorder setAllowedModifierFlags:NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask
                           requiredModifierFlags:0
                        allowsEmptyModifierFlags:NO];
    self.hotKeyRecorder.enabled = YES;
    
    self.integerNumberFormatter.allowsFloats = NO;
    
    _windowLayoutView = [[ZAFWindowLayoutView alloc] initWithFrame:self.windowLayoutViewPlaceHolder.bounds];
    _windowLayoutView.delegate = self;
    [_windowLayoutView setMinWidthPercent:kMinWidthPercent heightPercent:kMinHeightPercent];
    [self.windowLayoutViewPlaceHolder addSubview:_windowLayoutView];
    
    [self zaf_showLayoutItem];
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
    
    return [_layoutItem copy];
}


- (void)setLayoutItem:(ZAFLayoutItem*)layoutItem {
    
    NSParameterAssert(layoutItem != nil);
    
    _layoutItem = [layoutItem mutableCopy];
    [self zaf_showLayoutItem];
}


- (void)zaf_showLayoutItem {
    
    self.nameTextField.stringValue = _layoutItem.name;
    
    ZAFHotKey* hotKey = _layoutItem.hotKey;
    self.hotKeyRecorder.objectValue = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @(hotKey.keyCode),
                                       SRShortcutKeyCode,
                                       @(hotKey.keyModifiers),
                                       SRShortcutModifierFlagsKey,
                                       nil];
    
    ZAFFrame* frame = _layoutItem.frame;
    self.xPercentTextField.intValue = IntegerValueFromPercentValue(frame.xPercent);
    self.yPercentTextField.intValue = IntegerValueFromPercentValue(frame.yPercent);
    self.widthPercentTextField.intValue = IntegerValueFromPercentValue(frame.widthPercent);
    self.heightPercentTextField.intValue = IntegerValueFromPercentValue(frame.heightPercent);
    
    [_windowLayoutView changeWithXPercent:frame.xPercent
                                 yPercent:frame.yPercent
                             widthPercent:frame.widthPercent
                            heightPercent:frame.heightPercent];
}


- (IBAction)nameTextFieldDidChange:(id)sender {
    
    _layoutItem.name = self.nameTextField.stringValue;
}


- (IBAction)xTextFieldDidChange:(id)sender {

    double xPercent = PercentValueFromIntegerValue(self.xPercentTextField.intValue);
    [_windowLayoutView setXPercent:xPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.xPercent = xPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)yTextFieldDidChange:(id)sender {

    double yPercent = PercentValueFromIntegerValue(self.yPercentTextField.intValue);
    [_windowLayoutView setYPercent:yPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.yPercent = yPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)widthTextFieldDidChange:(id)sender {
    
    double widthPercent = PercentValueFromIntegerValue(self.widthPercentTextField.intValue);
    [_windowLayoutView setWidthPercent:widthPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.widthPercent = widthPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)heightTextFieldDidChange:(id)sender {
    
    double heightPercent = PercentValueFromIntegerValue(self.heightPercentTextField.intValue);
    [_windowLayoutView setHeightPercent:heightPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.heightPercent = heightPercent;
    _layoutItem.frame = newFrame;
}


- (void)shortcutRecorderDidEndRecording:(SRRecorderControl*)aRecorder {
    
    NSDictionary* hotKeyRecorderValues = self.hotKeyRecorder.objectValue;
    NSNumber* keyCodeNumber = [hotKeyRecorderValues objectForKey:SRShortcutKeyCode];
    NSNumber* keyModifiersNumber = [hotKeyRecorderValues objectForKey:SRShortcutModifierFlagsKey];
    
    if ( (keyCodeNumber != nil) && (keyModifiersNumber != nil) ) {
        
        _layoutItem.hotKey = [[ZAFHotKey alloc] initWithKeyCode:keyCodeNumber.intValue
                                                   keyModifiers:keyModifiersNumber.unsignedIntegerValue];
    }
    else {
        
        _layoutItem.hotKey = [ZAFHotKey emptyHotKey];
    }
}


- (void)windowLayoutDidChangeToXPercent:(double)xPercent
                               yPercent:(double)yPercent
                           widthPercent:(double)widthPercent
                          heightPercent:(double)heightPercent {
    
    self.xPercentTextField.intValue = IntegerValueFromPercentValue(xPercent);
    self.yPercentTextField.intValue = IntegerValueFromPercentValue(yPercent);
    self.widthPercentTextField.intValue = IntegerValueFromPercentValue(widthPercent);
    self.heightPercentTextField.intValue = IntegerValueFromPercentValue(heightPercent);
    
    _layoutItem.frame = [[ZAFFrame alloc] initWithXPercent:xPercent
                                                  yPercent:yPercent
                                              widthPercent:widthPercent
                                             heightPercent:heightPercent];
}


- (void)windowLayoutDidClear {
    
    self.xPercentTextField.stringValue = [NSString string];
    self.yPercentTextField.stringValue = [NSString string];
    self.widthPercentTextField.stringValue = [NSString string];
    self.heightPercentTextField.stringValue = [NSString string];
    
    _layoutItem.frame = [ZAFFrame emptyFrame];
}


- (IBAction)okButtonDidClick:(id)sender {
    
    [self nameTextFieldDidChange:self.nameTextField];
    [self xTextFieldDidChange:self.xPercentTextField];
    [self yTextFieldDidChange:self.yPercentTextField];
    [self widthTextFieldDidChange:self.widthPercentTextField];
    [self heightTextFieldDidChange:self.heightPercentTextField];
    [self shortcutRecorderDidEndRecording:self.hotKeyRecorder];
    
    if (_delegate != nil) {
        [_delegate editLayoutItemSheetWindowControllerDidFinishEditing];
    }
}


- (IBAction)cancelButtonDidClick:(id)sender {
    
    if (_delegate != nil) {
        [_delegate editLayoutItemSheetWindowControllerDidCancelEditing];
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

