//
//  NSObject+LJJSwizzlingShield.h
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

/**
 将 Method Swizzling 相关的方法封装起来。
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LJJSwizzlingShield)

/** 交换两个类方法的实现
 * @param originalSelector  原始方法的 SEL
 * @param swizzledSelector  交换方法的 SEL
 * @param targetClass  类
 */

+ (void)ljj_swizzlingClassMethod:(SEL)originalSelector  withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;

/** 交换两个对象方法的实现
 * @param originalSelector  原始方法的 SEL
 * @param swizzledSelector 交换方法的 SEL
 * @param targetClass  类
 */
+ (void)ljj_swizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;
@end

NS_ASSUME_NONNULL_END
