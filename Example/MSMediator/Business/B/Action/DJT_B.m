//
//  DJT_B.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "DJT_B.h"
#import "DJBViewController.h"

@implementation DJT_B

- (UIViewController *)DJA_detail:(NSDictionary *)params
{
    NSLog(@"[DJT_B] recieve params: %@", params);
    DJBViewController *vc = [[DJBViewController alloc] init];
    vc.title = params[@"title"];
    return vc;
}

@end
