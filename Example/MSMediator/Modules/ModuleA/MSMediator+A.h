//
//  MSMediator+A.h
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import <MSMediator/MSMediator.h>

@interface MSMediator (A)

- (UIViewController *)aDetailVC:(NSDictionary *)params;

- (void)login;

- (void)login:(void(^)(void))sucessBlock;

@end
