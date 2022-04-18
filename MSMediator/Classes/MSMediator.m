//
//  MSMediator.m
//  MSMediator
//
//  Created by Mengshun on 2021/5/24.
//

#import "MSMediator.h"

#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

NSString * const kMSMediatorKeySwiftTargetModuleName = @"kMSMediatorKeySwiftTargetModuleName";

@interface MSMediator ()

@property (strong, nonatomic) NSMutableDictionary *cachedTarget;
@property (copy, nonatomic) NSString *defaultSwiftModuleName;
@property (strong, nonatomic) MSMediatorBeforeInvokeBlock beforeInvokeBlock;
@property (strong, nonatomic) MSMediatorBeforeFinishBlock beforeFinishBlock;

@end

@implementation MSMediator

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static MSMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[MSMediator alloc] init];
        [mediator cachedTarget]; // 同时把cachedTarget初始化，避免多线程重复初始化
    });
    return mediator;
}

- (void)initSetupDefaultSwiftTargetModuleName:(NSString *)moduleName
{
    self.defaultSwiftModuleName = moduleName;
}

/*
 scheme://[target]/[action]?[params]
 
 url sample:
 aaa://targetA/actionB?id=1234
 */

- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    if (url == nil||![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    // 遍历所有参数
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.value&&obj.name) {
            [params setObject:obj.value forKey:obj.name];
        }
    }];
    
    // 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    // 这个demo针对URL的路由处理非常简单，就只是取对应的target名字和method名字，但这已经足以应对绝大部份需求。如果需要拓展，可以在这个方法调用之前加入完整的路由逻辑
    id result = [self performTarget:url.host action:actionName params:params shouldCacheTarget:NO];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget
{
    if (targetName.length > 0
        && actionName.length == 0) {
        // 如果只有 host  没有 path 走default  targetname 即为 action
        return [self defaultTargetAction:targetName params:params];
    }
    if (targetName.length == 0
        && actionName.length == 0) {
        // host 和 path 都没有则 直接返回 nil
        return nil;
    }
    
    // 两者都存在时 对 target 首字母 变大写处理
    if ([targetName isKindOfClass:NSString.class]) {
        targetName = [targetName capitalizedString];
    }
    
    NSString *swiftModuleName = params[kMSMediatorKeySwiftTargetModuleName];
    
    // generate target
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.DJT%@", swiftModuleName, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"DJT_%@", targetName];
    }
    NSObject *target = [self safeFetchCachedTarget:targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }
    
    if (target == nil
        && self.defaultSwiftModuleName) {
        targetClassString = [NSString stringWithFormat:@"%@.DJT%@", self.defaultSwiftModuleName, targetName];
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }

    // generate action
    NSString *actionString = [NSString stringWithFormat:@"DJA_%@:", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        // 这里是处理无响应请求的地方之一，这个demo做得比较简单，如果没有可以响应的target，就直接return了。实际开发过程中是可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求的
        [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        [self safeSetCachedTarget:target key:targetClassString];
    }

    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        // 这里是处理无响应请求的地方，如果无响应，则尝试调用对应target的notFound方法统一处理
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            // 这里也是处理无响应请求的地方，在notFound都没有的时候，这个demo是直接return了。实际开发过程中，可以用前面提到的固定的target顶上的。
            [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
            @synchronized (self) {
                [self.cachedTarget removeObjectForKey:targetClassString];
            }
            return nil;
        }
    }
}

- (MSMediator *)setupBeforeInvokeBlock:(MSMediatorBeforeInvokeBlock)block
{
    self.beforeInvokeBlock = block;
    return self;
}

- (MSMediator *)setupBeforeFinishBlock:(MSMediatorBeforeFinishBlock)block
{
    self.beforeFinishBlock = block;
    return self;
}

- (void)releaseCachedTargetWithFullTargetName:(NSString *)fullTargetName
{
    /*
     fullTargetName在oc环境下，就是Target_XXXX。要带上Target_前缀。在swift环境下，就是XXXModule.Target_YYY。不光要带上Target_前缀，还要带上模块名。
     */
    if (fullTargetName == nil) {
        return;
    }
    @synchronized (self) {
        [self.cachedTarget removeObjectForKey:fullTargetName];
    }
}

- (void)releaseAllCachedTargets
{
    @synchronized (self) {
        [self.cachedTarget removeAllObjects];
    }
}

#pragma mark - private methods

- (id)defaultTargetAction:(NSString *)actionName params:(NSDictionary *)params
{
    NSString *defaultTarget = @"DJT_Default";
    NSString *actionString = [NSString stringWithFormat:@"DJA_%@:", actionName];
    NSObject *target = [[NSClassFromString(defaultTarget) alloc] init];
    SEL action = NSSelectorFromString(actionString);
    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        [self NoTargetActionResponseWithTargetString:defaultTarget selectorString:actionString originParams:params];
    }
    return nil;
}

- (void)NoTargetActionResponseWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams
{
    SEL action = NSSelectorFromString(@"DJA_response:");
    NSObject *target = [[NSClassFromString(@"DJT_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    
    if (self.beforeInvokeBlock) {
        params = self.beforeInvokeBlock(params);
    }
    
    const char* retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id ret = [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    if (self.beforeFinishBlock) {
        return self.beforeFinishBlock(ret, params);
    } else {
        return ret;
    }
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedTarget
{
    if (_cachedTarget == nil) {
        _cachedTarget = [[NSMutableDictionary alloc] init];
    }
    return _cachedTarget;
}

- (NSObject *)safeFetchCachedTarget:(NSString *)key {
    @synchronized (self) {
        return self.cachedTarget[key];
    }
}

- (void)safeSetCachedTarget:(NSObject *)target key:(NSString *)key {
    @synchronized (self) {
        self.cachedTarget[key] = target;
    }
}


@end



@implementation NSString (MSMediator)

- (NSURL *)dj_URL
{
    NSURL *res = [NSURL URLWithString:self];
    if (!res) {
        NSCharacterSet *charset = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSMutableCharacterSet *mutSet = charset.mutableCopy;
        [mutSet addCharactersInString:@"#"];
        res = [NSURL URLWithString:[self stringByAddingPercentEncodingWithAllowedCharacters:mutSet]];
    }
    return res;
}

@end



@implementation NSURL (MSMediator)

- (NSDictionary *)dj_queryParams {
    NSURLComponents *coms = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (coms.queryItems.count) {
        [coms.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [dict setValue:obj.value forKey:obj.name];
        }];
    }
    return dict;
}

- (NSString *)dj_purePath {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
    return [self.path stringByTrimmingCharactersInSet:set];
}

- (NSURL *_Nonnull)dj_addParams:(NSDictionary <NSString *, NSString *>*_Nonnull)params
{
    NSMutableDictionary *resParams = [NSMutableDictionary dictionaryWithDictionary:[self dj_queryParams]];
    [resParams addEntriesFromDictionary:params];
    NSURLComponents *coms = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:NO];
    NSMutableArray <NSURLQueryItem *>* items = @[].mutableCopy;
    [resParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyStr = [NSString stringWithFormat:@"%@", key];
        NSString *objStr = obj;
        if ([obj isKindOfClass:NSNumber.class]) {
            objStr = [NSString stringWithFormat:@"%@", obj];
        } else if ([NSJSONSerialization isValidJSONObject:obj]) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingFragmentsAllowed error:&error];
            if ([jsonData length] > 0
                && !error) {
                objStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
            
        }
        if ([objStr isKindOfClass:NSString.class]) {
            [items addObject:[NSURLQueryItem queryItemWithName:keyStr value:objStr]];
        }
    }];
    coms.queryItems = items;
    return coms.URL ?: self;
}

@end


@implementation NSMutableDictionary (MSMediator)

static NSString *const _scheme_dj_ = @"_scheme_dj_";
static NSString *const _host_dj_ = @"_host_dj_";
static NSString *const _path_dj_ = @"_path_dj_";
static NSArray *_dj_url_components_key_array_ = nil;

+ (void)load
{
    if (!_dj_url_components_key_array_) {
        _dj_url_components_key_array_ = @[_scheme_dj_, _host_dj_, _path_dj_];
    }
}

- (MSMediatorBuildBlock)scheme {
    return ^(NSString *value){
        NSParameterAssert([value isKindOfClass:NSString.class]);
        if ([value isKindOfClass:NSString.class]) {
            self[_scheme_dj_] = value;
        }
        return self;
    };
}

- (MSMediatorBuildBlock)host {
    return ^(NSString *value){
        NSParameterAssert([value isKindOfClass:NSString.class]);
        if ([value isKindOfClass:NSString.class]) {
            self[_host_dj_] = value;
        }
        return self;
    };
}

- (MSMediatorBuildBlock)path {
    return ^(NSString *value){
        NSParameterAssert([value isKindOfClass:NSString.class]);
        if ([value isKindOfClass:NSString.class]) {
            self[_path_dj_] = value;
        }
        return self;
    };
}

- (MSMediatorParamsSetBlock)params {
    return ^(NSString *key, id value){
        NSParameterAssert([key isKindOfClass:NSString.class]);
        NSParameterAssert(value);
        if ([key isKindOfClass:NSString.class] && value) {
            [self setValue:value forKey:key];
        }
        return self;
    };
}

- (NSURL *)umake {
    NSParameterAssert(self[_scheme_dj_]);
    NSParameterAssert(self[_host_dj_]);
    if (self[_scheme_dj_] && self[_host_dj_]) {
        NSURLComponents *coms = [NSURLComponents new];
        coms.scheme = self[_scheme_dj_];
        coms.host = self[_host_dj_];
        coms.path = [self[_path_dj_] hasPrefix:@"/"] ? self[_path_dj_] : [@"/" stringByAppendingString:self[_path_dj_]];
        if (self.count) {
            NSMutableArray *queryItems = [NSMutableArray array];
            [self.copy enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (![_dj_url_components_key_array_ containsObject:key]) {
                    NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:key value:obj];
                    [queryItems addObject:item];
                }
            }];
            coms.queryItems = queryItems;
        }
        return [coms.URL copy];
    }
    return nil;
}

@end


MSMediator* _Nonnull DJ(void){
    return [MSMediator sharedInstance];
};
