#import "ZAFEditLayoutItemSheetWindowController.h"
#import <ShortcutRecorder/ShortcutRecorder.h>
#import "ZAFFrame.h"
#import "ZAFHotKey.h"
#import "ZAFLayoutItem.h"
#import "ZAFWindowLayoutView.h"


static int RoundedIntegerValueFromPercentValue(double percentValue);
static double PercentValueFromIntegerValue(int integerValue);
static BOOL ArePercentsRoundedEqual(double percent1, double percent2);


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

- (IBAction)nameTextFieldDidChange:(id)sender;
- (IBAction)xTextFieldDidChange:(id)sender;
- (IBAction)yTextFieldDidChange:(id)sender;
- (IBAction)widthTextFieldDidChange:(id)sender;
- (IBAction)heightTextFieldDidChange:(id)sender;

- (IBAction)okButtonDidClick:(id)sender;
- (IBAction)cancelButtonDidClick:(id)sender;

- (void)zaf_showLayoutItem;

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
    self.xPercentTextField.intValue = RoundedIntegerValueFromPercentValue(frame.xPercent);
    self.yPercentTextField.intValue = RoundedIntegerValueFromPercentValue(frame.yPercent);
    self.widthPercentTextField.intValue = RoundedIntegerValueFromPercentValue(frame.widthPercent);
    self.heightPercentTextField.intValue = RoundedIntegerValueFromPercentValue(frame.heightPercent);
    
    [_windowLayoutView changeWithXPercent:frame.xPercent
                                 yPercent:frame.yPercent
                             widthPercent:frame.widthPercent
                            heightPercent:frame.heightPercent];
}


- (IBAction)nameTextFieldDidChange:(id)sender {
    
    _layoutItem.name = self.nameTextField.stringValue;
}


- (IBAction)xTextFieldDidChange:(id)sender {

    double newXPercent = PercentValueFromIntegerValue(self.xPercentTextField.intValue);
    
    if (ArePercentsRoundedEqual(newXPercent, _windowLayoutView.xPercent)) {
        return;
    }
    
    [_windowLayoutView setXPercent:newXPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.xPercent = newXPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)yTextFieldDidChange:(id)sender {

    double newYPercent = PercentValueFromIntegerValue(self.yPercentTextField.intValue);

    if (ArePercentsRoundedEqual(newYPercent, _windowLayoutView.yPercent)) {
        return;
    }
    
    [_windowLayoutView setYPercent:newYPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.yPercent = newYPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)widthTextFieldDidChange:(id)sender {
    
    double newWidthPercent = PercentValueFromIntegerValue(self.widthPercentTextField.intValue);

    if (ArePercentsRoundedEqual(newWidthPercent, _windowLayoutView.widthPercent)) {
        return;
    }
    
    [_windowLayoutView setWidthPercent:newWidthPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.widthPercent = newWidthPercent;
    _layoutItem.frame = newFrame;
}


- (IBAction)heightTextFieldDidChange:(id)sender {
    
    double newHeightPercent = PercentValueFromIntegerValue(self.heightPercentTextField.intValue);

    if (ArePercentsRoundedEqual(newHeightPercent, _windowLayoutView.heightPercent)) {
        return;
    }
    
    [_windowLayoutView setHeightPercent:newHeightPercent];
    
    ZAFMutableFrame* newFrame = [_layoutItem.frame mutableCopy];
    newFrame.heightPercent = newHeightPercent;
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
    
    self.xPercentTextField.intValue = RoundedIntegerValueFromPercentValue(xPercent);
    self.yPercentTextField.intValue = RoundedIntegerValueFromPercentValue(yPercent);
    self.widthPercentTextField.intValue = RoundedIntegerValueFromPercentValue(widthPercent);
    self.heightPercentTextField.intValue = RoundedIntegerValueFromPercentValue(heightPercent);
    
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
    
    if ([self.window makeFirstResponder:nil]) {

        if (_delegate != nil) {
            [_delegate editLayoutItemSheetWindowControllerDidFinishEditing];
        }
    }
}


- (IBAction)cancelButtonDidClick:(id)sender {
    
    if (_delegate != nil) {
        [_delegate editLayoutItemSheetWindowControllerDidCancelEditing];
    }
}


@end



static int RoundedIntegerValueFromPercentValue(double percentValue) {
    
    if (percentValue < 0) {
        return 0;
    }
    else if (percentValue > 1) {
        return 1;
    }
    else {
        return round(percentValue * 100);
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


static BOOL ArePercentsRoundedEqual(double percent1, double percent2) {
    
    int roundedPercent1 = RoundedIntegerValueFromPercentValue(percent1);
    int roundedPercent2 = RoundedIntegerValueFromPercentValue(percent2);

    return roundedPercent1 == roundedPercent2;
}