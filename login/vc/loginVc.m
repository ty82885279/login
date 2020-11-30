//
//  loginVc.m
//  login
//
//  Created by MrLee on 2020/11/19.
//

#import "loginVc.h"
#import <TYAlertController/TYAlertController.h>
#import <UIView+TYAlertView.h>
#import <SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "ViewController.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "AppDelegate.h"


@interface loginVc ()

@end

@implementation loginVc

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)loginClick:(UIButton *)sender {
    

    if(_nameTF.text.length == 0||_pswTF.text.length==0){
        
        [SVProgressHUD showInfoWithStatus:@"请输入正确内容"];
        [SVProgressHUD dismissWithDelay:1];
    }
    
    NSMutableDictionary *parameDict = [NSMutableDictionary dictionary];
    [parameDict setValue:_nameTF.text forKey:@"name"];
    [parameDict setValue:_pswTF.text forKey:@"psw"];
    
  
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    
    
    [manager POST:@"http://192.168.3.180:8888/api/v1/login" parameters:parameDict headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {

      } success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
          
          NSLog(@"%@",responseObject);
          NSDictionary *respDic = (NSDictionary *)responseObject;
          NSInteger code = [respDic[@"code"] integerValue];
  
          if(code == 1001 ){
              [SVProgressHUD showInfoWithStatus:@"用户名或密码错误"];
              [SVProgressHUD dismissWithDelay:1.5];
              
          }
          if (code == 1000) {
              
              [self dismissViewControllerAnimated:YES completion:nil];
              [userInfo setValue:respDic[@"AccseeToken"] forKey:@"aToken"];
              [userInfo setValue:respDic[@"RefreshToken"] forKey:@"rToken"];
              [userInfo setValue:respDic[@"userID"] forKey:@"userID"];
              [userInfo setValue:@"1" forKey:@"login"];
              
               AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate ];
              [app jpushStartWithLaunchingWithOptions:app.launchOptions];
             
              
              
              NSString *alisa = [NSString stringWithFormat:@"%@_%@",respDic[@"userID"],[self getNowTimeStamp]];
              
              [JPUSHService setAlias:alisa completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                        
                    NSLog(@"------设置别名----");
                    NSLog(@"iResCode:--- %ld",iResCode);
                    NSLog(@"alisa:--- %@",iAlias);
                    NSLog(@"seq:--- %ld",seq);
                  if (iResCode == 0) {
                       
                      NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                      [dic setValue:alisa forKey:@"alisa"];
                      [dic setValue:[userInfo valueForKey:@"userID"] forKey:@"userID"];
                      [userInfo  setValue:alisa forKey:@"alisa"];
                      [manager POST:@"http://192.168.3.180:8888/api/v1/alisa" parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          
                                                
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          
                                                
                      }];
                  }
                  
              } seq:2];
              
              [userInfo setValue:alisa forKey:@"alisa"];
              
          }

      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"error：%@",error);
    }];
    
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
-(NSString *)getNowTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];

    NSTimeInterval a=[dat timeIntervalSince1970];

    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型

    return timeString;

}

@end
