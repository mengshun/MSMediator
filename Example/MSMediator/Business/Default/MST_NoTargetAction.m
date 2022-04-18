//
//  MST_NoTargetAction.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MST_NoTargetAction.h"

@implementation MST_NoTargetAction

- (void)MSA_response:(NSDictionary *)params
{
    NSLog(@"💣💣💣非法请求：%@", params);
}

@end
