//
//  MSMediator.h
//  MSMediator
//
//  Created by Mengshun on 2021/5/24.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const kMSMediatorKeySwiftTargetModuleName;

typedef id _Nullable(^MSMediatorBeforeFinishBlock)(id _Nullable object, NSDictionary *_Nullable params);
typedef id _Nullable(^MSMediatorBeforeInvokeBlock)(NSDictionary *_Nullable params);

@interface MSMediator : NSObject

+ (instancetype _Nonnull)sharedInstance;

/// 设置默认的 swift module name
- (void)initSetupDefaultSwiftTargetModuleName:(NSString *_Nonnull)moduleName;

/// 远程App调用入口
- (id _Nullable)performActionWithUrl:(NSURL * _Nullable)url completion:(void(^_Nullable)(NSDictionary * _Nullable info))completion;

/// 本地组件调用入口
- (id _Nullable )performTarget:(NSString * _Nullable)targetName action:(NSString * _Nullable)actionName params:(NSDictionary * _Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;

/// 查找 落地页 前 回调
- (MSMediator *_Nonnull)setupBeforeInvokeBlock:(MSMediatorBeforeInvokeBlock _Nullable)block;

/// 返回 落地结果前 回调
- (MSMediator *_Nonnull)setupBeforeFinishBlock:(MSMediatorBeforeFinishBlock _Nullable)block;

/// 释放缓存的指定 target 对象
- (void)releaseCachedTargetWithFullTargetName:(NSString * _Nullable)fullTargetName;

/// 释放所有缓存的 target 对象
- (void)releaseAllCachedTargets;

@end


@interface NSString (MSMediator)

/// 将字符串转为URL，如果url含有汉字等转义字符则编码一次
- (NSURL * _Nullable)dj_URL;

@end


@interface NSURL (MSMediator)

/// URL 中的 query items
- (NSDictionary *_Nonnull)dj_queryParams;

/// URL Path 移除所有的 /
- (NSString *_Nonnull)dj_purePath;

/// 向URL的 query 中追加参数， 会覆盖原有的重复参数
/// @param params  参数 dict
- (NSURL *_Nonnull)dj_addParams:(NSDictionary <NSString *, NSString *>*_Nonnull)params;

@end

typedef NSMutableDictionary * _Nonnull (^MSMediatorBuildBlock)(NSString * _Nonnull value);
typedef NSMutableDictionary * _Nonnull (^MSMediatorParamsSetBlock)(NSString * _Nonnull key, id _Nonnull value);

@interface NSMutableDictionary (MSMediator)

/// 方便手动组装跳转规则
@property (nonatomic, copy, readonly) MSMediatorBuildBlock _Nonnull scheme;
@property (nonatomic, copy, readonly) MSMediatorBuildBlock _Nonnull host;
@property (nonatomic, copy, readonly) MSMediatorBuildBlock _Nonnull path;
@property (nonatomic, copy, readonly) NSURL * _Nullable umake;  //组装完成后的规则

/// 更方便的追加参数
@property (nonatomic, copy, readonly) MSMediatorParamsSetBlock _Nonnull params;

@end




/// 简化调用单例的函数
MSMediator* _Nonnull DJ(void);

