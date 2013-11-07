//
//  AGSampleViewController.h
//  ShareSDKCredentialTransferSample
//
//  Created by Nogard on 13-10-28.
//  Copyright (c) 2013年 ShareSDK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGSampleViewController : UIViewController
{
    UIButton *myAuthButton;

    NSString *myCredential_userID;
    NSString *myCredential_accessToken;
    NSDate   *myCredential_expirationDate;
}

+ (NSString*)appKey;
+ (NSString*)appSecret;
+ (NSString*)redirectUri;
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;

@end
