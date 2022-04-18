//
//  MSMediator+Default.m
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import "MSMediator+Default.h"

@implementation MSMediator (Default)

- (id)jumpWithURLString:(NSString *)jumpString params:(NSDictionary *)params
{
    NSURL *jumpURL = [jumpString ms_URL];
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    [paramters addEntriesFromDictionary:jumpURL.ms_queryParams];
    [paramters addEntriesFromDictionary:params];
    NSString *target = jumpURL.host;
    NSString *actionName = jumpURL.ms_purePath;
    return [self performTarget:target action:actionName params:paramters shouldCacheTarget:NO];
}

@end
