//
//  NSObject+LJJKVCShield.h
//  LJJShield
//
//  Created by 刘俊杰 on 2019/9/2.
//  Copyright © 2019 刘俊杰. All rights reserved.
//
/**
 KVC 日常使用造成崩溃的原因通常有以下几个：
 
 key 不是对象的属性，造成崩溃。
 keyPath 不正确，造成崩溃。
 key 为 nil，造成崩溃。
 value 为 nil，为非对象设值，造成崩溃。
 
 解决方案分析
 KVC 在执行时，具体的搜索模式。也就是 KVC 内部的执行流程。根据了解了 KVC 内部的具体执行流程，我们才能知道在哪个步骤对其进行防护。
 
 一.KVC Setter 搜索模式
 系统在执行 setValue:forKey: 方法时，会把 key 和 value 作为输入参数，并尝试在接收调用对象的内部，给属性 key 设置 value 值。通过以下几个步骤：
 (1).按顺序查找名为 set<Key>:、_set<Key>: 、setIs<Key>: 方法。如果找到方法，则执行该方法，使用输入参数设置变量，则 setValue:forKey: 完成执行。如果没找到方法，则执行下一步。
 (2).访问类的 accessInstanceVariablesDirectly 属性。如果 accessInstanceVariablesDirectly 属性返回 YES，就按顺序查找名为 _<key>、_is<Key>、<key>、is<Key> 的实例变量，如果找到了对应的实例变量，则使用输入参数设置变量。则 setValue:forKey: 完成执行。如果未找到对应的实例变量，或者 accessInstanceVariablesDirectly 属性返回 NO 则执行下一步。
 (3).调用 setValue: forUndefinedKey: 方法，并引发崩溃。
 
 示例
 [objc setValue:@"value" forKey:@"name"];
 setName:方法 ------>执行
    |
 没有找到
    |
 _setName:方法 ------>执行
    |
 没有找到
    |
 setIsName:方法 ------>执行
    |
 没有找到
    |
 accessInstanceVariablesDirectly(是否同意访问成员变量) --返回YES-> 寻找(_name, _isName, name, isName)变量
    |
  返回NO
    |
   异常
 
 二.KVC Getter 搜索模式
 系统在执行 valueForKey: 方法时，会将给定的 key 作为输入参数，在调用对象的内部进行以下几个步骤：
 (1).按顺序查找名为 get<Key>、<key>、is<Key>、_<key> 的访问方法。如果找到，调用该方法，并继续执行步骤
 (2).搜索形如 countOf<Key>、objectIn<Key>AtIndex:、<key>AtIndexes: 的方法。
 如果实现了 countOf<Key> 方法，并且实现了 objectIn<Key>AtIndex: 和 <key>AtIndexes: 这两个方法的任意一个方法，系统就会以 NSArray 为父类，动态生成一个类型为 NSKeyValueArray 的集合类对象，并调用上边的实现方法，将结果直接返回。
 如果对象还实现了形如 get<Key>:range: 的方法，系统也会在必要的时候自动调用。
 如果上述操作不成功则继续向下执行步骤
 (3).如果上边两步失败，系统就会查找形如 countOf<Key>、enumeratorOf<Key>、memberOf<Key>: 的方法。系统会自动生成一个 NSSet 类型的集合类对象，该对象响应所有 NSSet 方法并将结果返回。如果查找失败，则执行步骤
 (4).如果上边三步失败，系统就会访问类的 accessInstanceVariablesDirectly 方法。
    如果返回 YES，就按顺序查找名为 _<key>、_is<Key>、<key>、is<Key> 的实例变量。如果找到了对应的实例变量，则直接获取实例变量的值。并继续执行步骤
 (5)分为三种情况：
 如果检索到的属性值是对象指针，则直接返回结果。
 如果检索到的属性值是 NSNumber 支持的基础数据类型，则将其存储在 NSNumber 实例中并返回该值。
 如果检索到的属性值是 NSNumber 不支持的数据类型，则转换为 NSValue 对象并返回该对象。
 (6)如果一切都失败了，调用 valueForUndefinedKey:，并引发崩溃。
 
 解决方案
 (1).setValue:forKey: 执行失败会调用 setValue: forUndefinedKey: 方法，并引发崩溃。
 (2).valueForKey: 执行失败会调用 valueForUndefinedKey: 方法，并引发崩溃。
 为了进行 KVC Crash 防护，我们就需要重写 setValue: forUndefinedKey: 方法和 valueForUndefinedKey: 方法。重写这两个方法之后，就可以防护 1. key 不是对象的属性 和 2. keyPath 不正确 这两种崩溃情况了。
 
 (3).key 为 nil，造成崩溃
    利用 Method Swizzling 方法，在 NSObject 的分类中将 setValue:forKey: 和 ysc_setValue:forKey: 进行方法交换。然后在自定义的方法中，添加对 key 为 nil 这种类型的判断。
 (4) value 为 nil
    重写 setNilValueForKey: 来解决。
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LJJKVCShield)

@end

NS_ASSUME_NONNULL_END
