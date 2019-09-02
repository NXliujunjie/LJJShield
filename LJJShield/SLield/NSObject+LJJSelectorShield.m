//
//  NSObject+LJJSelectorShield.m
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

#import "NSObject+LJJSelectorShield.h"
#import "LJJSlield.h"

static int Crash(id self, SEL seletor) {
    return 0;
}

@implementation NSObject (LJJSelectorShield)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 拦截 `-forwardingTargetForSelector:` 方法，替换自定义实现
        [NSObject ljj_swizzlingInstanceMethod:@selector(forwardingTargetForSelector:) withMethod:@selector(ljj_forwardingTargetForSelector:) withClass:[NSObject class]];
        
        [NSObject ljj_swizzlingClassMethod:@selector(forwardingTargetForSelector:)
                                       withMethod:@selector(ljj_forwardingClassTargetForSelector:)
                                        withClass:[NSObject class]];
    });
}

#pragma mark:-- 拦截 实例对象 `-forwardingTargetForSelector:` 方法，替换自定义实现
- (id)ljj_forwardingTargetForSelector:(SEL)aSelector {
    SEL forwarding_sel = @selector(forwardingTargetForSelector:);
    // 获取 NSObject 的消息转发方法
    Method root_forwarding_method = class_getInstanceMethod([NSObject class], forwarding_sel);
    // 获取 当前类 的消息转发方法
    Method current_forwarding_method = class_getInstanceMethod([self class], forwarding_sel);
    // 判断当前类本身是否实现第二步:消息接受者重定向
    BOOL realize = method_getImplementation(current_forwarding_method) != method_getImplementation(root_forwarding_method);
    // 如果没有实现第二步:消息接受者重定向
    if (!realize) {
        // 判断有没有实现第三步:消息重定向
        SEL methodSignature_sel = @selector(methodSignatureForSelector:);
        Method root_methodSignature_method = class_getInstanceMethod([NSObject class], methodSignature_sel);
        Method current_methodSignature_method = class_getInstanceMethod([self class], methodSignature_sel);
        realize = method_getImplementation(current_methodSignature_method) != method_getImplementation(root_methodSignature_method);
        // 如果没有实现第三步:消息重定向
        if (!realize) {
            // 创建一个新类
            NSString *errClassName = NSStringFromClass([self class]);
            NSString *errSel = NSStringFromSelector(aSelector);
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"errClassName:%@, errSel:%@",errClassName,errSel] code:100 userInfo:@{@"errClassName":[self class], @"errSel":NSStringFromSelector(aSelector)}];
            NSLog(@"%@",error);
            NSString *className = @"CrachClass";
            Class cls = NSClassFromString(className);
            // 如果类不存在 动态创建一个类
            if (!cls) {
                Class superClsss = [NSObject class];
                cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                objc_registerClassPair(cls);
            }
            // 如果类没有对应的方法，则动态添加一个
            if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                class_addMethod(cls, aSelector, (IMP)Crash, "@@:@");
            }
            // 把消息转发到当前动态生成类的实例对象上
            return [[cls alloc] init];
        }
    }
    return [self ljj_forwardingTargetForSelector:aSelector];
}

#pragma mark:-- 拦截类对象 `-forwardingTargetForSelector:` 方法，替换自定义实现
+ (id)ljj_forwardingClassTargetForSelector:(SEL)aSelector {
    SEL forwarding_sel = @selector(forwardingTargetForSelector:);
    // 获取 NSObject 的消息转发方法
    Method root_forwarding_method = class_getClassMethod([NSObject class], forwarding_sel);
    // 获取 当前类 的消息转发方法
    Method current_forwarding_method = class_getClassMethod([self class], forwarding_sel);
    
    // 判断当前类本身是否实现第二步:消息接受者重定向
    BOOL realize = method_getImplementation(current_forwarding_method) != method_getImplementation(root_forwarding_method);
    // 如果没有实现第二步:消息接受者重定向
    if (!realize) {
        // 判断有没有实现第三步:消息重定向
        SEL methodSignature_sel = @selector(methodSignatureForSelector:);
        Method root_methodSignature_method = class_getClassMethod([NSObject class], methodSignature_sel);
        Method current_methodSignature_method = class_getClassMethod([self class], methodSignature_sel);
        realize = method_getImplementation(current_methodSignature_method) != method_getImplementation(root_methodSignature_method);
        // 如果没有实现第三步:消息重定向
        if (!realize) {
            // 创建一个新类
            NSString *errClassName = NSStringFromClass([self class]);
            NSString *errSel = NSStringFromSelector(aSelector);
            NSError *error = [NSError errorWithDomain:[NSString stringWithFormat:@"errClassName:%@, errSel:%@",errClassName,errSel] code:100 userInfo:@{@"errClassName":[self class], @"errSel":NSStringFromSelector(aSelector)}];
            NSLog(@"%@",error);
            NSString *className = @"CrachClass";
            Class cls = NSClassFromString(className);
            // 如果类不存在 动态创建一个类
            if (!cls) {
                Class superClsss = [NSObject class];
                cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                // 注册类
                objc_registerClassPair(cls);
            }
            // 如果类没有对应的方法，则动态添加一个
            if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                class_addMethod(cls, aSelector, (IMP)Crash, "@@:@");
            }
            // 把消息转发到当前动态生成类的实例对象上
            return [[cls alloc] init];
        }
    }
    return [self ljj_forwardingClassTargetForSelector:aSelector];
}
@end
