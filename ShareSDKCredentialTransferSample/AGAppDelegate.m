//
//  AGAppDelegate.m
//  ShareSDKCredentialTransferSample
//
//  Created by Nogard on 13-10-28.
//  Copyright (c) 2013年 ShareSDK. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGSampleViewController.h"
#import <ShareSDK/ShareSDK.h>


@implementation AGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WeiboSDK registerApp:[AGSampleViewController appKey]];
    [WeiboSDK enableDebugMode:YES];


    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    // Override point for customization after application launch.

    AGSampleViewController *vc = [[AGSampleViewController alloc] init];

    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    [ShareSDK registerApp:@"api20"];
    [ShareSDK connectSinaWeiboWithAppKey:[AGSampleViewController appKey]
                               appSecret:[AGSampleViewController appSecret]
                             redirectUri:[AGSampleViewController redirectUri]];
    [ShareSDK ssoEnabled:NO];

    return YES;
}


- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
    }
}


- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        [(AGSampleViewController*)(self.window.rootViewController) didReceiveWeiboResponse:response];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [WeiboSDK handleOpenURL:url delegate:self];
    NSLog(@"[application:openURL:sourceApplication:annotation:] %@, %d", url, result);
    return result;
}

@end
