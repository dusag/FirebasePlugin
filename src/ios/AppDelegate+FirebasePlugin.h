#import "AppDelegate.h"

@import UserNotifications;
#import "Firebase.h"

@interface AppDelegate (FirebasePlugin) <FIRMessagingDelegate, UNUserNotificationCenterDelegate>

@end
