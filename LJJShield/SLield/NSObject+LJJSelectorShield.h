//
//  NSObject+LJJSelectorShield.h
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

/**
 消息转发机制有三大步骤：消息动态解析、消息接受者重定向、消息重定向。
 1. 消息动态解析：Objective-C 运行时会调用 +resolveInstanceMethod: 或者 +resolveClassMethod:，让你有机会提供一个函数实现。我们可以通过重写这两个方法，添加其他函数实现，并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。若返回 NO 或者没有添加其他函数实现，则进入下一步。
 2. 消息接受者重定向：如果当前对象实现了 forwardingTargetForSelector:，Runtime 就会调用这个方法，允许我们将消息的接受者转发给其他对象。如果这一步方法返回 nil，则进入下一步。
 3. 消息重定向：Runtime 系统利用 methodSignatureForSelector: 方法获取函数的参数和返回值类型。
 
 封装第二步（消息接受者重定向）来进行拦截。因为 -forwardingTargetForSelector 方法可以将消息转发给一个对象，开销较小，并且被重写的概率较低，适合重写。
 具体步骤如下：
 1: 给 NSObject 添加一个分类，在分类中实现一个自定义的 forwardingTargetForSelector: 方法；
 2: 利用 Method Swizzling 将 -forwardingTargetForSelector: 和 -forwardingTargetForSelector: 进行方法交换。
 3:在自定义的方法中，先判断当前对象是否已经实现了消息接受者重定向和消息重定向。如果都没有实现，就动态创建一个目标类，给目标类动态添加一个方法。
 4:把消息转发给动态生成类的实例对象，由目标类动态创建的方法实现，这样 APP 就不会崩溃了。
 */
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LJJSelectorShield)

@end

NS_ASSUME_NONNULL_END
