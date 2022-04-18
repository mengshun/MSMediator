//
//  DJT_NoTargetAction.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "DJT_NoTargetAction.h"

@implementation DJT_NoTargetAction

- (void)DJA_response:(NSDictionary *)params
{
    NSLog(@"💣💣💣非法请求：%@", params);
}

@end
