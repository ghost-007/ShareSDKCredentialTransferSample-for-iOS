//
//  AGSampleViewController.m
//  ShareSDKCredentialTransferSample
//
//  Created by Nogard on 13-10-28.
//  Copyright (c) 2013年 ShareSDK. All rights reserved.
//

#import "AGSampleViewController.h"
#import "WeiboSDK.h"
#import <ShareSDK/ShareSDK.h>
#import <SinaWeiboConnection/ISSSinaWeiboApp.h>
#import <AGCommon/UIDevice+Common.h>


static NSString *kAppKey      = @"568898243";
static NSString *kAppSecret   = @"38a4f8204cc784f81f9f0daaf31e02e3";
static NSString *kRedirectUri = @"http://www.sharesdk.cn";

static NSString *kAuthButtonTitle  = @"获取授权";
static NSString *kShareButtonTitle = @"测试分享";

@interface AGSampleViewController ()

@end

@implementation AGSampleViewController

+ (NSString*)appKey
{
    return kAppKey;
}

+ (NSString*)appSecret
{
    return kAppSecret;
}

+ (NSString*)redirectUri
{
    return kRedirectUri;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myAuthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeStatusForButton:myAuthButton forInit:YES];
    [self.view addSubview:myAuthButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)authButtonClicked:(id)sender
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kRedirectUri;
    request.scope = @"all";
    [WeiboSDK sendRequest:request];
}


- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    NSString *title = @"授权失败";
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess)
    {
        title = @"授权成功";
        [self changeStatusForButton:myAuthButton forInit:NO];
    }
    myCredential_accessToken = [[(WBAuthorizeResponse *)response accessToken] copy];
    myCredential_userID = [[(WBAuthorizeResponse *)response userID] copy];
    myCredential_expirationDate = [[(WBAuthorizeResponse*)response expirationDate] copy];

    NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
                         response.statusCode,
                         myCredential_userID,
                         myCredential_accessToken,
                         response.userInfo,
                         response.requestUserInfo];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    [self changeStatusForButton:myAuthButton forInit:NO];
}


- (void)changeStatusForButton:(UIButton*)button forInit:(BOOL)isForInit
{
    if (isForInit)
    {
        [myAuthButton setTitle:kAuthButtonTitle
                      forState:UIControlStateNormal];
        [myAuthButton sizeToFit];

        CGFloat width = myAuthButton.frame.size.width;
        CGFloat height = myAuthButton.frame.size.height;
        CGFloat x = (self.view.frame.size.width - width) / 2;
        CGFloat y = (self.view.frame.size.height) * (1.0-0.618);
        CGRect frame = CGRectMake(x, y, width, height);
        [myAuthButton setFrame:frame];
        [myAuthButton addTarget:self
                         action:@selector(authButtonClicked:)
               forControlEvents:UIControlEventTouchUpInside];
        return;
    }

    if ([[[button titleLabel] text] compare:kAuthButtonTitle] == NSOrderedSame)
    {
        [button setTitle:kShareButtonTitle
                 forState:UIControlStateNormal];
        [button sizeToFit];
        [button removeTarget:self
                      action:@selector(authButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self
                   action:@selector(shareButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)shareButtonClicked:(id)sender
{
    //TODO: 1. 从新浪微博SDK中得到的数据，转化成需要的字典对象
    NSDictionary *dict = @{
            @"access_token" : myCredential_accessToken,
            @"expires_in" : [NSNumber numberWithDouble:[myCredential_expirationDate timeIntervalSinceNow]],
            @"uid" : myCredential_userID
    };

    //TODO: 2. 调用ShareSDK的方法，将字典对象转化为ISSCredential对象
    id<ISSCredential> cred =
    [ShareSDK credentialWithSourceData:dict
                                  type:ShareTypeSinaWeibo];

    //TODO: 3. 将Credential导入ShareSDK
    [ShareSDK setCredential:cred
                       type:ShareTypeSinaWeibo];

    //TODO: 4. 配合ShareSDK connectSinaWeibo 就可以完成导入授权并测试分享（不再需要授权）
    id<ISSContainer> container = [ShareSDK container];

    if ([[UIDevice currentDevice] isPad])
        [container setIPadContainerWithView:sender
                                arrowDirect:UIPopoverArrowDirectionUp];
    else
        [container setIPhoneContainerWithViewController:self];

    id<ISSContent> content = 
    [ShareSDK content:@"从新浪微博SDK导入授权，不再重复授权 @ShareSDK"
       defaultContent:@""
                image:nil
                title:nil
                  url:nil
          description:nil
            mediaType:SSPublishContentMediaTypeText];

    id<ISSShareOptions> shareOptions =
    [ShareSDK simpleShareOptionsWithTitle:@"分享内容"
                        shareViewDelegate:nil];

    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:content
                      statusBarTips:NO
                        authOptions:nil
                       shareOptions:shareOptions
                             result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 NSString *message = nil;

                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     message = @"分享成功";
                                     UIAlertView *alertView =
                                     [[UIAlertView alloc] initWithTitle:@"测试结果"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                                     [alertView show];
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     message = [NSString stringWithFormat:@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription] ];
                                     UIAlertView *alertView =
                                     [[UIAlertView alloc] initWithTitle:@"测试结果"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil];
                                     [alertView show];
                                 }
                             }];
}

@end
