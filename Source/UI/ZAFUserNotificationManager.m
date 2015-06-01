#import "ZAFUserNotificationManager.h"
#import "ZAFLocalization.h"
#import "ZAFRuntimeNotifications.h"


@interface ZAFUserNotificationManager () {
    
    
}

- (void)zaf_changeFocusedWindowWithoutTrustedNotification:(NSNotification*)notification;

@end



@implementation ZAFUserNotificationManager


- (id)init {
    
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(zaf_changeFocusedWindowWithoutTrustedNotification:)
                                                     name:ZAFMoveAndResizeFocusedWindowWithouTrustedNotification
                                                   object:nil];

    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
}


- (void)zaf_changeFocusedWindowWithoutTrustedNotification:(NSNotification*)notification {
    
    NSUserNotification* userNotification = [[NSUserNotification alloc] init];
    userNotification.hasActionButton = NO;
    userNotification.title = ZAFGetLocalizedString(@"NotTrustedNotificationTitle");
    userNotification.informativeText = ZAFGetLocalizedString(@"NotTrustedNotificationInformativeText");
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
}



@end
