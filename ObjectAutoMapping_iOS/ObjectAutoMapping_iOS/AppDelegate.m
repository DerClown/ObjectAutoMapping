//
//  AppDelegate.m
//  ObjectAutoMapping
//
//  Created by User on 12/11/14.
//  Copyright (c) 2014 liuxudong. All rights reserved.
//

#import "AppDelegate.h"
#import "JosnModel.h"
#import "JsonShipModel.h"
#import "CustomJsonModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor whiteColor];
    self.window = window;
    
    NSError *errorMsg;
    
    NSLog(@"*********************CustomJsonModel****************************\r");
    CustomJsonModel *customModel = [[CustomJsonModel alloc] initWithSoureceObject:@{@"name":@"小红", @"country":@"中国", @"otherInfos":@[@"我", @"你", @"他"]} error:&errorMsg];
    NSLog(@"\r %@ \r", customModel);
    
    
    
    NSLog(@"*********************JosnModel****************************\r");
    NSArray *array = @[@{@"avatar":@"http://www.baidu.com"}, @{@"avatar":@"http://www.baidu.com"}];
    JosnModel *model = [[JosnModel alloc] initWithSoureceObject:@{@"username" : @"小米哥", @"password":@"123456", @"avatar":array} error:&errorMsg];
    NSLog(@"\r %@ %@ \r", model , errorMsg);
    
    
    
    NSLog(@"\r***************************JsonShipModel*******************************\r");
    JsonShipModel *shipModel = [[JsonShipModel alloc] initWithSoureceObject:@{@"thumb_Image":@"http://www.my.img.png", @"products":@[@"product1", @"product2"], @"personal_info":@{@"id":@"99129", @"firstname":@"小明", @"lastname":@"刘"}} error:&errorMsg];
    
    
    
    NSLog(@"shipMapping %@ \r", shipModel);
    NSLog(@"\r ***********************************************************************\r");
    
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
