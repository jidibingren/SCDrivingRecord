//
//  AppDelegate.m
//  SCDrivingRecord
//
//  Created by SC on 16/8/8.
//  Copyright © 2016年 SDJY. All rights reserved.
//

#import "AppDelegate.h"

#ifdef BAIDU_MAP
@interface AppDelegate ()<BMKGeneralDelegate>
@property (nonatomic, strong)BMKMapManager *mapManager;
#else
@interface AppDelegate ()
#endif

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [[SCDrivingRecord sharedInstance] startMonitoringLocation:YES];
        
        return YES;
        
    }else{
        
        [[SCDrivingRecord sharedInstance] startMonitoringLocation:NO];
        
    }
    
    [self setUpRootViewController];
    
    return YES;
}

- (void)setUpRootViewController{
    
    if (!self.window) {
        
        // Override point for customization after application launch.
        self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[SCRoutingListController new]];
        [self.window makeKeyAndVisible];
#ifdef BAIDU_MAP
        _mapManager = [[BMKMapManager alloc] init];
        //[self requestMessage:@"1,2,3,4"];
        //    如果要关注网络及授权验证事件，请设定 generalDelegate
        BOOL ret = [_mapManager start:BAIDU_MAP_KEY generalDelegate:self];
        if (!ret) {
            NSLog(@"manager start failed");
        }
#elif defined AMap3D
        [MAMapServices sharedServices].apiKey=ALI_MAP_KEY;
#else
        [AMapServices sharedServices].apiKey=ALI_MAP_KEY;
#endif
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [[SCDrivingRecord sharedInstance] restartMonitoringLocation];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[SCDrivingRecord sharedInstance] startMonitoringLocation:NO];
    
    [self setUpRootViewController];
    
    [[SCDrivingRecord sharedInstance] dataProcessing:SCMotionTypeAutomotive];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// implementation of BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(NSLocalizedString(@"联网成功", nil));
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(NSLocalizedString(@"授权成功", nil));
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

@end
