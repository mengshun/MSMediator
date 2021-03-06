//
//  MST_Default.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MST_Default.h"

#import "MSMediator_Example-Swift.h"

@implementation MST_Default

- (void)MSA_login:(NSDictionary *)params
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
