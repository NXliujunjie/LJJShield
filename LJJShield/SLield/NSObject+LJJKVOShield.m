//
//  NSObject+LJJKVOShield.m
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

#import "NSObject+LJJKVOShield.h"
#import "LJJSlield.h"

// 判断是否是系统类
static inline BOOL IsSystemClass(Class cls){
    BOOL isSystem = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"] || [className hasPrefix:@"__NS"] || [className hasPrefix:@"OS_xpc"]) {
        isSystem = YES;
        return isSystem;
    }
    NSBundle *mainBundle = [NSBundle bundleForClass:cls];
    if (mainBundle == [NSBundle mainBundle]) {
        isSystem = NO;
    }else{
        isSystem = YES;
    }
    return isSystem;
}

@interface LJJKVOProxy : NSObject
// 获取所有被观察的 keyPaths
- (NSArray *)getAllKeyPaths;
@end

@implementation LJJKVOProxy{
    // 关系数据表结构：{keypath : [observer1, observer2 , ...](NSHashTable)}
@private
    NSMutableDictionary<NSString *, NSHashTable<NSObject *> *> *_kvoInfoMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvoInfoMap = [NSMutableDictionary dictionary];
    }
    return self;
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)addInfoToMapWithObserver:(NSObject *)observer
                      forKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context {
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        if (info.count == 0) {
            info = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
            [info addObject:observer];
            _kvoInfoMap[keyPath] = info;
            return YES;
        }
        if (![info containsObject:observer]) {
            [info addObject:observer];
        }
        return NO;
    }
}

// 移除 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath {
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        if (info.count == 0) {
            return NO;
        }
        [info removeObject:observer];
        
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            return YES;
        }
        return NO;
    }
}

// 添加 KVO 信息操作, 添加成功返回 YES
- (BOOL)removeInfoInMapWithObserver:(NSObject *)observer
                         forKeyPath:(NSString *)keyPath
                            context:(void *)context {
    @synchronized (self) {
        if (!observer || !keyPath ||
            ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
        if (info.count == 0) {
            return NO;
        }
        [info removeObject:observer];
        if (info.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            return YES;
        }
        return NO;
    }
}

// 实际观察者 yscKVOProxy 进行监听，并分发
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSHashTable<NSObject *> *info = _kvoInfoMap[keyPath];
    for (NSObject *observer in info) {
        @try {
            [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : %@",[exception description]];
            NSLog(@"%@",reason);
        }
    }
}

// 获取所有被观察的 keyPaths
- (NSArray *)getAllKeyPaths {
    NSArray <NSString *>*keyPaths = _kvoInfoMap.allKeys;
    return keyPaths;
}
@end


@implementation NSObject (LJJKVOShield)

static void *LJJKVOProxyKey = &LJJKVOProxyKey;
static NSString *const KVODefenderValue = @"YSC_KVODefender";
static void *KVODefenderKey = &KVODefenderKey;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 拦截 `addObserver:forKeyPath:options:context:` 方法，替换自定义实现
        [NSObject ljj_swizzlingInstanceMethod: @selector(addObserver:forKeyPath:options:context:)
                                   withMethod: @selector(ysc_addObserver:forKeyPath:options:context:)
                                    withClass: [NSObject class]];
        
        // 拦截 `removeObserver:forKeyPath:` 方法，替换自定义实现
        [NSObject ljj_swizzlingInstanceMethod: @selector(removeObserver:forKeyPath:)
                                   withMethod: @selector(ysc_removeObserver:forKeyPath:)
                                    withClass: [NSObject class]];
        
        // 拦截 `removeObserver:forKeyPath:context:` 方法，替换自定义实现
        [NSObject ljj_swizzlingInstanceMethod: @selector(removeObserver:forKeyPath:context:)
                                   withMethod: @selector(ysc_removeObserver:forKeyPath:context:)
                                    withClass: [NSObject class]];
        
        // 拦截 `dealloc` 方法，替换自定义实现
        [NSObject ljj_swizzlingInstanceMethod: NSSelectorFromString(@"dealloc")
                                   withMethod: @selector(ysc_kvodealloc)
                                    withClass: [NSObject class]];
    });
}

// YSCKVOProxy setter 方法
- (void)setYscKVOProxy:(LJJKVOProxy *)yscKVOProxy {
    objc_setAssociatedObject(self, LJJKVOProxyKey, yscKVOProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// YSCKVOProxy getter 方法
- (LJJKVOProxy *)yscKVOProxy {
    id yscKVOProxy = objc_getAssociatedObject(self, LJJKVOProxyKey);
    if (yscKVOProxy == nil) {
        yscKVOProxy = [[LJJKVOProxy alloc] init];
        self.yscKVOProxy = yscKVOProxy;
    }
    return yscKVOProxy;
}

// 自定义 addObserver:forKeyPath:options:context: 实现方法
- (void)ysc_addObserver:(NSObject *)observer
             forKeyPath:(NSString *)keyPath
                options:(NSKeyValueObservingOptions)options
                context:(void *)context {
    
    if (!IsSystemClass(self.class)) {
        objc_setAssociatedObject(self, KVODefenderKey, KVODefenderValue, OBJC_ASSOCIATION_RETAIN);
        if ([self.yscKVOProxy addInfoToMapWithObserver:observer forKeyPath:keyPath options:options context:context]) {
            // 如果添加 KVO 信息操作成功，则调用系统添加方法
            [self ysc_addObserver:self.yscKVOProxy forKeyPath:keyPath options:options context:context];
        } else {
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

// 自定义 removeObserver:forKeyPath:context: 实现方法
- (void)ysc_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath
                   context:(void *)context {
    
    if (!IsSystemClass(self.class)) {
        if ([self.yscKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath context:context]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath context:context];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer", observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

// 自定义 removeObserver:forKeyPath: 实现方法
- (void)ysc_removeObserver:(NSObject *)observer
                forKeyPath:(NSString *)keyPath {
    
    if (!IsSystemClass(self.class)) {
        if ([self.yscKVOProxy removeInfoInMapWithObserver:observer forKeyPath:keyPath]) {
            // 如果移除 KVO 信息操作成功，则调用系统移除方法
            [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath];
        } else {
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer", observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    } else {
        [self ysc_removeObserver:observer forKeyPath:keyPath];
    }
    
}

// 自定义 dealloc 实现方法
- (void)ysc_kvodealloc {
    @autoreleasepool {
        if (!IsSystemClass(self.class)) {
            NSString *value = (NSString *)objc_getAssociatedObject(self, KVODefenderKey);
            if ([value isEqualToString:KVODefenderValue]) {
                NSArray *keyPaths =  [self.yscKVOProxy getAllKeyPaths];
                // 被观察者在 dealloc 时仍然注册着 KVO
                if (keyPaths.count > 0) {
                    NSString *reason = [NSString stringWithFormat:@"KVO Warning : An instance %@ was deallocated while key value observers were still registered with it. The Keypaths is:'%@'", self, [keyPaths componentsJoinedByString:@","]];
                    NSLog(@"%@",reason);
                }
                // 移除多余的观察者
                for (NSString *keyPath in keyPaths) {
                    [self ysc_removeObserver:self.yscKVOProxy forKeyPath:keyPath];
                }
            }
        }
    }
    [self ysc_kvodealloc];
}

@end
