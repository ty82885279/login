//
//  AppDelegate.m
//  login
//
//  Created by MrLee on 2020/11/19.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "ViewController.h"
#import "loginVc.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "HomeViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.application = application;
    self.launchOptions = launchOptions;
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];

    //
    HomeViewController *home = [[HomeViewController alloc]init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *my = [storyboard instantiateViewControllerWithIdentifier:@"Main"];

    home.tabBarItem.title = @"首页";
    my.tabBarItem.title = @"我的";
    
    UITabBarController *tab = [[UITabBarController alloc]init];
    
    [tab addChildViewController:home];
    [tab addChildViewController:my];
    
    //
    _window.rootViewController =tab;
 
    //
    loginVc *loginVC = [[loginVc alloc]init];
    loginVC.modalPresentationStyle = 0;
    [_window makeKeyAndVisible];
    
    NSString *tag = [[NSUserDefaults standardUserDefaults]valueForKey:@"login"];
    if(tag == NULL){
        
        NSLog(@"没有登陆");
        [_window.rootViewController presentViewController:loginVC  animated:NO completion:^{
            [tab setSelectedIndex:0];
        }];
    }else{
        NSLog(@"已经登陆");
    }
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        // 当网络状态改变时调用
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                    NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"没有网络");
                
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"手机自带网络");
            {dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self jpushStartWithLaunchingWithOptions:launchOptions];
            });}
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                    NSLog(@"WIFI");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self jpushStartWithLaunchingWithOptions:launchOptions];
                });}
                break;
        }
    }];
    
    //开始监控
    [manager startMonitoring];
    return YES;
}

-(void)jpushStartWithLaunchingWithOptions:(NSDictionary *)options{
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    [JPUSHService setupWithOption:options appKey:@"c2c65fe9fc05f649becea714"
                          channel:@"Appstore"
                 apsForProduction:true
            advertisingIdentifier:nil];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID成功,code:%d",resCode);
            
            [userInfo setValue:registrationID forKey:@"regis"];
            
        }else {
//            NSLog(@"registrationID获取失败,code:%d",resCode);
            
        }
    }];
    
}

- (NSString *)j:(NSString *)base64String
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return string;
}

//添加处理APNs通知回调方法
#pragma mark- JPUSHRegisterDelegate
// iOS 10 Support 前台获取通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    [JPUSHService setBadge:0];
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support  后台获取通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

//注册APNs成功并上报DeviceToken
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

//实现注册APNs失败接口（可选
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


- (void)applicationWillResignActive:(UIApplication *)application {
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (AFHTTPSessionManager *)createAFHTTPSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求参数的类型:HTTP (AFJSONRequestSerializer,AFHTTPRequestSerializer)
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    
    //设置请求的超时时间
    manager.requestSerializer.timeoutInterval = 60.f;
    //设置服务器返回结果的类型:JSON (AFJSONResponseSerializer,AFHTTPResponseSerializer)
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    return manager;
}

//
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSLog(@"接收到的消息：%@",notification.userInfo);
    NSString *item = notification.userInfo[@"content"];
//    NSLog(@"链接：%@",item);
    [self makeItem:item];
}
-(void)makeItem:(NSString *)item{
    
    if ([item isEqualToString:@"重复登陆"]) {
        
        UIAlertAction *act =[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            //清空本地数据
            NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
            
            loginVc *log = [[loginVc alloc]init];
            log.modalPresentationStyle = 0;
            [[self getCurrentVC] presentViewController:log animated:YES completion:nil];
            
        }];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的账户已经在其他设备登录" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:act];
        alert.modalPresentationStyle = 0;
        
        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
}
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }

    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}
@end
