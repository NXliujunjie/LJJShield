//
//  LJJSlield.h
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//

/**
 参考链接:https://bujige.net
 unrecognized selector sent to instance（找不到对象方法的实现）
 unrecognized selector sent to class（找不到类方法实现）
 KVO Crash
 KVC Crash
 NSNotification Crash
 NSTimer Crash
 Container Crash（集合类操作造成的崩溃，例如数组越界，插入 nil 等）
 NSString Crash （字符串类操作造成的崩溃）
 Bad Access Crash （野指针）
 Threading Crash （非主线程刷 UI）
 NSNull Crash
 */
#ifndef LJJSlield_h
#define LJJSlield_h

#import "NSObject+LJJSwizzlingShield.h"
#import "NSObject+LJJSelectorShield.h"
#import <objc/runtime.h>
#endif /* LJJSlield_h */
