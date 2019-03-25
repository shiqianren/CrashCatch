//
//  NSObject+Dict.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "NSObject+Dict.h"
#import <objc/runtime.h>
#import <pthread.h>

@implementation NSObject (Dict)

+ (void)openDictCP{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(initWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"rwx_initWithObjects:forKeys:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSPlaceholderDictionary") orginalMethod:@selector(dictionaryWithObjects:forKeys:count:) replaceMethod:NSSelectorFromString(@"rwx_dictionaryWithObjects:forKeys:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSDictionaryM") orginalMethod:@selector(setObject:forKey:) replaceMethod:NSSelectorFromString(@"rwx_setObject:forKey:")];
        
    });
}


//在进行方法swizzing时候，一定要注意类簇 ，比如 NSArray NSDictionary 等。
+ (BOOL)swizzlingInstanceMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector
{
    return [self swizzlingInstance:self orginalMethod:originalSelector replaceMethod:replaceSelector];
}

+(BOOL)swizzlingInstance:(Class)clz orginalMethod:(SEL)originalSelector  replaceMethod:(SEL)replaceSelector{
    
    Method original = class_getInstanceMethod(clz, originalSelector);
    Method replace = class_getInstanceMethod(clz, replaceSelector);
    BOOL didAddMethod =
    class_addMethod(clz,
                    originalSelector,
                    method_getImplementation(replace),
                    method_getTypeEncoding(replace));
    
    if (didAddMethod) {
        class_replaceMethod(clz,
                            replaceSelector,
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, replace);
    }
    return YES;
}

+ (BOOL)swizzlingClass:(Class)klass replaceClassMethod:(SEL)methodSelector1 withMethod:(SEL)methodSelector2
{
    if (!klass || !methodSelector1 || !methodSelector2) {
        NSLog(@"Nil Parameter(s) found when swizzling.");
        return NO;
    }
    
    Method method1 = class_getClassMethod(klass, methodSelector1);
    Method method2 = class_getClassMethod(klass, methodSelector2);
    if (method1 && method2) {
        IMP imp1 = method_getImplementation(method1);
        IMP imp2 = method_getImplementation(method2);
        
        Class classMeta = object_getClass(klass);
        if (class_addMethod(classMeta, methodSelector1, imp2, method_getTypeEncoding(method2))) {
            class_replaceMethod(classMeta, methodSelector2, imp1, method_getTypeEncoding(method1));
        } else {
            method_exchangeImplementations(method1, method2);
        }
        return YES;
    } else {
        NSLog(@"Swizzling Method(s) not found while swizzling class %@.", NSStringFromClass(klass));
        return NO;
    }
}


@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSDictionary (CrashProtector)
//  fix
@implementation NSDictionary (CrashProtector)

- (instancetype)rwx_initWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            NSLog(@"need log msg");
            
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return  [self rwx_initWithObjects:safeObjects forKeys:safeKeys count:j];
}


+ (instancetype)rwx_dictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    id safeKeys[cnt];
    
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id key = keys[i];
        id obj = objects[i];
        if (!key || !obj) {
            NSLog(@"need log msg");
            continue;
        }
        safeObjects[j] = obj;
        safeKeys[j] = key;
        j++;
    }
    return [self rwx_dictionaryWithObjects:safeObjects forKeys:safeKeys count:j];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSMutableDictionary (CrashProtector)
//  fix
@implementation NSMutableDictionary (CrashProtector)

- (void)rwx_setObject:(nullable id)anObject forKey:(nullable id <NSCopying>)aKey{
    if (!anObject || !aKey) {
        NSLog(@"need log msg");
        return;
    }
    [self rwx_setObject:anObject forKey:aKey];
}

@end
