#import "AIAppDelegate.h"
#import "AIAppsViewController.h"

@implementation AIAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    AIAppsViewController *apps = [[AIAppsViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:apps];
    navigation.navigationBar.prefersLargeTitles = YES;
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
