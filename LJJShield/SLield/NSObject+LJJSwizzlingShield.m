//
//  NSObject+LJJSwizzlingShield.m
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

#import "NSObject+LJJSwizzlingShield.h"
#import "LJJSlield.h"

#pragma mark:-- 交换两个类方法的实现 C 函数
static void ljj_swizzlingClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark:-- 交换两个对象方法的实现 C 函数
static void ljj_swizzlingInstanceMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation NSObject (LJJSwizzlingShield)

#pragma mark:-- 交换两个类方法的实现 OC 函数
+ (void)ljj_swizzlingClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass {
    ljj_swizzlingClassMethod(targetClass, originalSelector, swizzledSelector);
}

#pragma mark:-- 交换两个对象方法的实现 C 函数
+ (void)ljj_swizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass {
    ljj_swizzlingInstanceMethod(targetClass, originalSelector, swizzledSelector);
}
@end
