//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
#import "BusinessManager.h"
#import "CommonTools.h"




@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

//- (void)dealloc {
//    self.delegate = nil;
//    [super dealloc];
//}

#pragma mark - WXApiDelegate


- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvMessageResponse:)]) {
            SendMessageToWXResp *messageResp = (SendMessageToWXResp *)resp;
            [_delegate managerDidRecvMessageResponse:messageResp];
        }
    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAddCardResponse:)]) {
            AddCardToWXCardPackageResp *addCardResp = (AddCardToWXCardPackageResp *)resp;
            [_delegate managerDidRecvAddCardResponse:addCardResp];
        }
    }
}



- (void)onReq:(BaseReq *)req {
    int i =0;
    
    i ++;
    
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvGetMessageReq:)]) {
            GetMessageFromWXReq *getMessageReq = (GetMessageFromWXReq *)req;
            [_delegate managerDidRecvGetMessageReq:getMessageReq];
        }
    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvShowMessageReq:)]) {
            ShowMessageFromWXReq *showMessageReq = (ShowMessageFromWXReq *)req;
            [_delegate managerDidRecvShowMessageReq:showMessageReq];
        }
    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvLaunchFromWXReq:)]) {
            LaunchFromWXReq *launchReq = (LaunchFromWXReq *)req;
            [_delegate managerDidRecvLaunchFromWXReq:launchReq];
        }
    }
}

- (void) refreshToken
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    
    // [[NSUserDefaults standardUserDefaults] setObject:@"ap" forKey:REFRESHTOKEN];
    
    
    
    NSString* RefreshToken = [[NSUserDefaults standardUserDefaults] objectForKey:REFRESHTOKEN];
    
    if (nil == RefreshToken) {
        return;
    }
    
    NSString *requestURl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=wx11e7c8929bb425c6&grant_type=refresh_token&refresh_token=%@",RefreshToken ];
    
    
    
    [manager GET:requestURl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *res  = (NSDictionary *)responseObject;
             
             [WXApiManager sharedManager].access_token = [res objectForKey:@"access_token"];
             [WXApiManager sharedManager].openid = [res objectForKey:@"openid"];
             [self getuserInfo];
//             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                 [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_WX_REFRESH_TOKEN object:[NSNumber numberWithBool:1]];
//             });
             return;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //             failure(error);
             
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_WX_REFRESH_TOKEN object:[NSNumber numberWithBool:0]];
             });
             
             return ;
         }];
    return;
}


- (void) getuserInfo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    
    
    NSString *requestURl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", [WXApiManager sharedManager].access_token, [WXApiManager sharedManager].openid];
    
    
    [manager GET:requestURl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary* postResponseDic = (NSDictionary *)responseObject;
             
             //getUserInfo
             
             //
             [[NSNotificationCenter defaultCenter] postNotificationName: RECEIVE_WX_REGISTER object:postResponseDic];
             
            
             //
             return;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //             failure(error);
             
             int i = 0;
             i++;
             
             return ;
         }];
    
    return;
}


@end
