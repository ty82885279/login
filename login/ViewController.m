//
//  ViewController.m
//  login
//
//  Created by MrLee on 2020/11/19.
//

#import "ViewController.h"
#import "loginVc.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
  

    
}

- (IBAction)exit:(UIButton *)sender {
    
    [self logout];
    
}

-(void)logout{
    
    NSMutableDictionary *parameDict = [NSMutableDictionary dictionary];
    
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userInfo valueForKey:@"userID"];
    
    [parameDict setValue:userID forKey:@"userID"];
    
    [manager POST:@"http://192.168.3.180:8888/api/v1/logout" parameters:parameDict headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {

      } success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
          
          NSLog(@"%@",responseObject);
          NSDictionary *respDic = (NSDictionary *)responseObject;
          NSInteger code = [respDic[@"code"] integerValue];
  
          if (code == 1000) {
              
              [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                  NSLog(@"------删除别名----");
                  NSLog(@"iResCode:--- %ld",iResCode);
                  NSLog(@"alisa:--- %@",iAlias);
                  NSLog(@"seq:--- %ld",seq);
                                
              } seq:1];
              
              //清空NSUserDefaults
              NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
              [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
              
              
              loginVc *log = [[loginVc alloc]init];
              log.modalPresentationStyle = 0;
              [self presentViewController:log animated:YES completion:nil];
              
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
@end
