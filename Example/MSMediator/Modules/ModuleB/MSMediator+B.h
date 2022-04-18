//
//  MSMediator+B.h
//  MSMediator_Example
//
//  Created by Mengshun on 2021/5/25.
//  Copyright © 2021 shun.meng. All rights reserved.
//

#import <MSMediator/MSMediator.h>

@interface MSMediator (B)

- (UIViewController *)bDetailVCTitle:(NSString *)title
                               prdId:(NSString *)prdId
                              params:(NSDictionary *)params;

@end
