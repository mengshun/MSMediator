//
//  MST_B.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MST_B.h"
#import "DJBViewController.h"

@implementation MST_B

- (UIViewController *)MSA_detail:(NSDictionary *)params
{
    NSLog(@"[MST_B] recieve params: %@", params);
    DJBViewController *vc = [[DJBViewController alloc] init];
    vc.title = params[@"title"];
    return vc;
}

@end
