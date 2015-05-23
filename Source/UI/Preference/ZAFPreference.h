#import <Foundation/Foundation.h>


@interface ZAFPreference : NSObject

+ (ZAFPreference*)sharedPreference;

- (BOOL)hasPromptedForTrusting;
- (void)setHasPromptedForTrusting:(BOOL)hasPrompted;

- (BOOL)launchApplicationAtLogin;
- (void)setLaunchApplicationAtLogin:(BOOL)launch;

- (BOOL)showIconOnStatusBar;
- (void)setShowIconOnStatusBar:(BOOL)show;

@end
