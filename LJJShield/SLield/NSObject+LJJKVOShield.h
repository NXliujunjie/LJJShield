//
//  NSObject+LJJKVOShield.h
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//
/**
 KVO 日常使用造成崩溃的原因通常有以下几个：
 KVO 添加次数和移除次数不匹配：
 移除了未注册的观察者，导致崩溃。
 重复移除多次，移除次数多于添加次数，导致崩溃。
 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
 被观察者提前被释放，被观察者在 dealloc 时仍然注册着 KVO，导致崩溃。
 例如：被观察者是局部变量的情况（iOS 10 及之前会崩溃）。
 添加了观察者，但未实现 observeValueForKeyPath:ofObject:change:context: 方法，导致崩溃。
 添加或者移除时 keypath == nil，导致崩溃。
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LJJKVOShield)

@end

NS_ASSUME_NONNULL_END
