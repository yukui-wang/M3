//
//  SOSwizzle.m
//  LocalizationExample
//
//  Created by scfhao on 2017/11/27.
//  Copyright © 2017年 scfhao. All rights reserved.
//

#import "SOSwizzle.h"
#import <objc/runtime.h>


void SOSwizzleClassMethod(Class clz, SEL originalSelector, SEL swizzledSelector) {
    Class originalMetaClz = object_getClass(clz);
    Class swizzledMetaClz = object_getClass(clz);
    
    Method originalMethod = class_getClassMethod(originalMetaClz, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledMetaClz, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(originalMetaClz,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(originalMetaClz,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


void SOSwizzleInstanceMethod(Class clz, SEL originalSelector, SEL swizzledSelector) {
    /**class_getInstanceMethod实际上就是调用了runtime里写的IMP lookUpImpOrNil(Class cls, SEL sel, id inst,
    bool initialize, bool cache, bool resolver)函数，这个函数作用是在给定类的方法列表和方法cache列表中查找给定的方法的实现。
     这个方法会在以此从此类的cache和方法列表中查找这个方法的实现，一旦找到就存储在cache中并返回
     也就说这个方法获取到的方法实现可能会是父类甚至是父类的父类的方法实现
     同样的，在方法调用的时候，一样会首先执行这个查找方法。当你的子类和父类用一个同名的方法对另一个同名的方法进行交换之后，调用子类的那个方法时，就会出现循环调用的问题，最终导致程序crash。
     因此，在具有继承关系时，对同一个方法进行方法交换时，一定要将子类自定义的方法的名字和父类不一样才行，不然一定会出现魂环调用的问题**/
    
    Method originalMethod = class_getInstanceMethod(clz, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(clz, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void SOSwizzlefDifferentClassInstanceMethod(Class originalClass,Class swizzledClass,SEL originalSelector, SEL swizzledSelector) {
    
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}
