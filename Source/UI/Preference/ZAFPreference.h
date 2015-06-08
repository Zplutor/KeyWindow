#import <Foundation/Foundation.h>


@interface ZAFPreference : NSObject

+ (ZAFPreference*)sharedPreference;

- (BOOL)isFistTimeLaunched;
- (void)setIsFirstTimeLaunched:(BOOL)isFirstTime;

- (BOOL)launchApplicationAtLogin;
- (void)setLaunchApplicationAtLogin:(BOOL)launch;

- (BOOL)showIconOnStatusBar;
- (void)setShowIconOnStatusBar:(BOOL)show;

- (BOOL)hasPromptedForTrusting;
- (void)setHasPromptedForTrusting:(BOOL)hasPrompted;

@end
