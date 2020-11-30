//
//  AppDelegate.h
//  login
//
//  Created by MrLee on 2020/11/19.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UIApplication *application;
@property (strong,nonatomic) NSDictionary *launchOptions;
-(void)jpushStartWithLaunchingWithOptions:(NSDictionary *)options;
@end

