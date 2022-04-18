//
//  MSMediator+A.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MSMediator+A.h"

@implementation MSMediator (A)

- (UIViewController *)aDetailVC:(NSDictionary *)params
{
    return [self performTarget:@"A" action:@"detail" params:nil shouldCacheTarget:NO];
}

- (void)login
{
    [self performTarget:@"A" action:@"login" params:nil shouldCacheTarget:NO];
}

- (void)login:(void (^)(void))sucessBlock
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:sucessBlock forKey:@"completion"];
    [self performTarget:@"A" action:@"login" params:params shouldCacheTarget:NO];
}

@end
