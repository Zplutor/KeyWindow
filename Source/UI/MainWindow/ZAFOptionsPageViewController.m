#import "ZAFOptionsPageViewController.h"
#import "ZAFPreference.h"
#import "ZAFUINotifications.h"


@interface ZAFOptionsPageViewController ()

@property (nonatomic, weak) IBOutlet NSButton* showIconOnStatusBarCheckBox;
@property (nonatomic, weak) IBOutlet NSButton* launchAtLoginCheckBox;

- (IBAction)showIconOnStatusBarCheckBoxDidClick:(id)sender;
- (IBAction)launchAtLoginCheckBoxDidClick:(id)sender;

@end



@implementation ZAFOptionsPageViewController


+ (ZAFOptionsPageViewController*)create {
    
    return [[ZAFOptionsPageViewController alloc] initWithNibName:@"OptionsPageView" bundle:[NSBundle mainBundle]];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];

    BOOL showIconOnStatusBar = [[ZAFPreference sharedPreference] showIconOnStatusBar];
    self.showIconOnStatusBarCheckBox.state = showIconOnStatusBar ? NSOnState : NSOffState;
    
    BOOL launchAtLogin = [[ZAFPreference sharedPreference] launchApplicationAtLogin];
    self.launchAtLoginCheckBox.state = launchAtLogin ? NSOnState : NSOffState;
}


- (IBAction)showIconOnStatusBarCheckBoxDidClick:(id)sender {
    
    BOOL isOn = self.showIconOnStatusBarCheckBox.state == NSOnState;
    
    [[ZAFPreference sharedPreference] setShowIconOnStatusBar:isOn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ZAFShowIconOnStatusBarOptionDidChangeNotification
                                                        object:self
                                                      userInfo:@{ ZAFBoolValueKey: @(isOn) }];
}


- (IBAction)launchAtLoginCheckBoxDidClick:(id)sender {
    
    BOOL isOn = self.launchAtLoginCheckBox.state == NSOnState;
    
    [[ZAFPreference sharedPreference] setLaunchApplicationAtLogin:isOn];
}


@end
