#import "ZAFPreference.h"
#import "ZAFLoginItemService.h"


static NSString* const kIsFirstTimeLaunched = @"IsFirstTimeLaunched";
static NSString* const kShowIconOnStatusBarKey = @"ShowIconOnStatusBar";


@interface ZAFPreference () {
    
    BOOL _hasPromptedForTrusting;
}

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
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{ kIsFirstTimeLaunched: @(YES),
                                                                   kShowIconOnStatusBarKey: @(YES) }];
        
        _hasPromptedForTrusting = NO;
    }
    return self;
}


- (BOOL)isFistTimeLaunched {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstTimeLaunched];
}


- (void)setIsFirstTimeLaunched:(BOOL)isFirstTime {
    
    [[NSUserDefaults standardUserDefaults] setBool:isFirstTime forKey:kIsFirstTimeLaunched];
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


- (BOOL)hasPromptedForTrusting {
    return _hasPromptedForTrusting;
}

- (void)setHasPromptedForTrusting:(BOOL)hasPrompted {
    _hasPromptedForTrusting = hasPrompted;
}


@end
