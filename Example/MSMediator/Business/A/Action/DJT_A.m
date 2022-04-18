//
//  DJT_A.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "DJT_A.h"
#import "DJAViewController.h"
#import "MSMediator_Example-Swift.h"

@implementation DJT_A

- (UIViewController *)DJA_detail:(NSDictionary *)params
{
    NSLog(@"[DJT_A] recieve params: %@", params);
    return [[DJAViewController alloc] init];
}

- (void)DJA_login:(NSDictionary *)params
{
    void(^block)(void) = params[@"completion"];
    DJLoginViewController *vc = [[DJLoginViewController alloc] init];
    if (block) {
        vc.loginSuccessBlock = block;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
}

@end
