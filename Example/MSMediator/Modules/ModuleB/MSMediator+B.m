//
//  MSMediator+B.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MSMediator+B.h"

@implementation MSMediator (B)

- (UIViewController *)bDetailVCTitle:(NSString *)title
                               prdId:(NSString *)prdId
                              params:(NSDictionary *)params
{
    NSMutableDictionary *paramters = [NSMutableDictionary dictionaryWithDictionary:params];
    if (title.length > 0) {
        [paramters setValue:title forKey:@"title"];
    }
    
    if (prdId.length > 0) {
        [paramters setValue:prdId forKey:@"prdId"];
    }
    return [self performTarget:@"B" action:@"detail" params:paramters shouldCacheTarget:NO];
}

@end
