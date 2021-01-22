#import "AppDelegate+FirebasePlugin.h"
#import "FirebasePlugin.h"
#import <objc/runtime.h>
#import "Firebase.h"


@implementation AppDelegate (FirebasePlugin)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method original = class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
        Method swizzled = class_getInstanceMethod(self, @selector(application:swizzledDidFinishLaunchingWithOptions:));
        method_exchangeImplementations(original, swizzled);
    });
}

- (BOOL)application:(UIApplication *)application swizzledDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self application:application swizzledDidFinishLaunchingWithOptions:launchOptions];
    
    if(![FIRApp defaultApp]) {
        [FIRApp configure];
    }
    
    [FIRMessaging messaging].delegate = self;
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDictionary *mutableUserInfo = [userInfo mutableCopy];
    
    NSNumber *inBackground = (application.applicationState != UIApplicationStateActive) ? @(YES) : @(NO);
    [mutableUserInfo setValue:inBackground forKey:@"tap"];
    
    // Pring full message.
    NSLog(@"%@", mutableUserInfo);
    
    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    [FirebasePlugin.firebasePlugin sendToken:fcmToken];
}

# pragma mark - UNUserNotificationCenterDelegate
// handle incoming notification messages while app is in the foreground
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(void))completionHandler {
   
    NSDictionary *mutableUserInfo = [notification.request.content.userInfo mutableCopy];
    
    [mutableUserInfo setValue:@(YES) forKey:@"tap"];
    
    // Pring full message.
    NSLog(@"%@", mutableUserInfo);
    
    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
    
    completionHandler();
}

// handle notification messages after display notification is tapped by the user
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    
    NSDictionary *mutableUserInfo = [response.notification.request.content.userInfo mutableCopy];
    
    [mutableUserInfo setValue:@(YES) forKey:@"tap"];
    
    // Pring full message.
    NSLog(@"%@", mutableUserInfo);
    
    [FirebasePlugin.firebasePlugin sendNotification:mutableUserInfo];
    
    completionHandler();
}

@end
