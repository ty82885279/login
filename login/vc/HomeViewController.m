//
//  HomeViewController.m
//  login
//
//  Created by MrLee on 2020/11/26.
//

#import "HomeViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "loginVc.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)post:(UIButton *)sender {
    
    NSLog(@"点击发布");
    
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    NSString *aToken = [userInfo valueForKey:@"aToken"];
    NSString *userID = [userInfo valueForKey:@"userID"];
    NSDictionary *headerDict = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",aToken]};
    
    
    NSLog(@"------ %@",headerDict);
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:userID forKey:@"userID"];
    AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
    [manager POST:@"http://192.168.3.180:8888/api/v1/post" parameters:paramDict headers:headerDict progress:^(NSProgress * _Nonnull downloadProgress) {

      } success:^(NSURLSessionDataTask * _Nonnull task, id responseObject) {
          
          NSLog(@"%@",responseObject);
          NSDictionary *respDic = (NSDictionary *)responseObject;
          NSInteger code = [respDic[@"code"] integerValue];
          if(code == 1003 ){
              [SVProgressHUD showInfoWithStatus:@"请求头缺少token"];
              [SVProgressHUD dismissWithDelay:2];
              
          }
          if(code == 100 ){
              [SVProgressHUD showInfoWithStatus:@"发布成功"];
              [SVProgressHUD dismissWithDelay:1.5];
              
          }
          if(code == 1000 ){
              [SVProgressHUD showSuccessWithStatus:@"发布成功"];
              [SVProgressHUD dismissWithDelay:1.5];
              
          }
          if(code == 10086){
              [SVProgressHUD showInfoWithStatus:@"AToken过期，刷新token中"];
              [SVProgressHUD dismissWithDelay:1.5];
              
              NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
              NSString *aToken = [userInfo valueForKey:@"aToken"];
              NSString *rToken = [userInfo valueForKey:@"rToken"];
              NSDictionary *headerDict = @{@"Authorization":[NSString stringWithFormat:@"Bearer %@",aToken]};
              
              
              NSLog(@"------ %@",headerDict);
              NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
              [paramDict setValue:rToken forKey:@"refresh_token"];
              [paramDict setValue:userID forKey:@"userID"];
              AFHTTPSessionManager *manager = [self createAFHTTPSessionManager];
              [manager POST:@"http://192.168.3.180:8888/api/v1/token" parameters:paramDict headers:headerDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  NSLog(@"%@",responseObject);
                  NSDictionary *respDic = (NSDictionary *)responseObject;
                  NSInteger code = [respDic[@"code"] integerValue];
                  if(code == 10000 ){
                      [SVProgressHUD showSuccessWithStatus:@"刷新成功"];
                      [SVProgressHUD dismissWithDelay:2];
                      
                      [userInfo setValue:respDic[@"access_token"] forKey:@"aToken"];
                      [userInfo setValue:respDic[@"refresh_token"] forKey:@"rToken"];
                      [userInfo synchronize];
                      
                  }
                  if(code == 1002 ){
                      [SVProgressHUD showInfoWithStatus:@"token错误"];
                      [SVProgressHUD dismissWithDelay:2];
                      
                  }
                  if(code == 1003 ){
                      [SVProgressHUD showInfoWithStatus:@"请求头中Token格式错误"];
                      [SVProgressHUD dismissWithDelay:2];
                      
                  }
                  if(code == 10087 ){
                      [SVProgressHUD showInfoWithStatus:@"Rtoken过期,请重新登陆"];
                      [SVProgressHUD dismissWithDelay:2];
                      
                      NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                      [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
                      
                      
                      loginVc *log = [[loginVc alloc]init];
                      log.modalPresentationStyle = 0;
                      [self presentViewController:log animated:YES completion:nil];
                  }

                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      
                    NSLog(@"刷新 token error：%@",error);
                }];
              
          }
          if(code == 10087){
              [SVProgressHUD showInfoWithStatus:@"RToken过期，请重新登录"];
              [SVProgressHUD dismissWithDelay:1.5];
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
