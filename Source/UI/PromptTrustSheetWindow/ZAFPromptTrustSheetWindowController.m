#import "ZAFPromptTrustSheetWindowController.h"


@interface ZAFPromptTrustSheetWindowController ()

- (IBAction)turnOnSettingButtonDidClick:(id)sender;

@end



@implementation ZAFPromptTrustSheetWindowController


+ (ZAFPromptTrustSheetWindowController*)create {
    
    return [[ZAFPromptTrustSheetWindowController alloc] initWithWindowNibName:@"PromptTrustSheetWindow"];
}


- (IBAction)turnOnSettingButtonDidClick:(id)sender {
    
    if (_delegate != nil) {
        [_delegate promptTrustSheetWindowDidClose];
    }
}


@end
