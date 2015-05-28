#import "ZAFAboutPageViewController.h"


static NSString* GetApplicationVersion();


@interface ZAFAboutPageViewController ()

@property (nonatomic, weak) IBOutlet NSImageView* iconView;
@property (nonatomic, weak) IBOutlet NSTextField* versionLabel;

@end


@implementation ZAFAboutPageViewController



+ (ZAFAboutPageViewController*)create {

    return [[ZAFAboutPageViewController alloc] initWithNibName:@"AboutPageView" bundle:[NSBundle mainBundle]];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.iconView.image = [[NSApplication sharedApplication] applicationIconImage];
    self.versionLabel.stringValue = [NSString stringWithFormat:@"KeyWindow %@", GetApplicationVersion()];
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

