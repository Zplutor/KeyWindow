#import "ZAFPreference.h"
#import "ZAFLoginItemService.h"


static NSString* const kHasPromptedForTrusting = @"HasPromptedForTrusting";
static NSString* const kShowIconOnStatusBarKey = @"ShowIconOnStatusBar";


@interface ZAFPreference ()

- (ZAFLoginItem*)zaf_loginItemOfCurrentApplication;

@end


@implementation ZAFPreference


+ (ZAFPreference*)sharedPreference {
    
    static ZAFPreference* instance = [[ZAFPreference alloc] init];
    return instance;
}


- (id)init {
    
    self = [super init];
    if (self) {
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kHasPromptedForTrusting: @(NO),
                                                                   kShowIconOnStatusBarKey: @(YES) }];
    }
    return self;
}


- (BOOL)hasPromptedForTrusting {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasPromptedForTrusting];
}


- (void)setHasPromptedForTrusting:(BOOL)hasPrompted {
    
    [[NSUserDefaults standardUserDefaults] setBool:hasPrompted forKey:kHasPromptedForTrusting];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)launchApplicationAtLogin {
    
    return [self zaf_loginItemOfCurrentApplication] != nil;
}


- (void)setLaunchApplicationAtLogin:(BOOL)launch {
    
    ZAFLoginItem* loginItem = [self zaf_loginItemOfCurrentApplication];
    
    if (launch) {
    
        //已经设置了登录时启动，不需要再次设置
        if (loginItem != nil) {
            return;
        }
        
        NSURL* applicationUrl = [[NSBundle mainBundle] bundleURL];
        [[ZAFLoginItemService defaultService] addOrUpdateLoginItemWithUrl:applicationUrl
                                                               setOptions:nil
                                                             clearOptions:nil];
    }
    else {
        
        [[ZAFLoginItemService defaultService] deleteLoginItem:loginItem];
    }
}


- (ZAFLoginItem*)zaf_loginItemOfCurrentApplication {
    
    NSURL* applicationUrl = [[NSBundle mainBundle] bundleURL];
    
    NSArray* loginItems = [[ZAFLoginItemService defaultService] loginItems];
    for (ZAFLoginItem* eachItem in loginItems) {
        
        if ([eachItem.url isEqualTo:applicationUrl]) {
            return eachItem;
        }
    }
    
    return nil;
}


- (BOOL)showIconOnStatusBar {

    return [[NSUserDefaults standardUserDefaults] boolForKey:kShowIconOnStatusBarKey];
}


- (void)setShowIconOnStatusBar:(BOOL)show {

    [[NSUserDefaults standardUserDefaults] setBool:show forKey:kShowIconOnStatusBarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
