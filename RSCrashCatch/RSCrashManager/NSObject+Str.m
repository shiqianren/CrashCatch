//
//  NSObject+Str.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "NSObject+Str.h"
#import <objc/runtime.h>
#import <pthread.h>
@implementation NSObject (Str)

+ (void)openStrCP{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzlingInstance:objc_getClass("NSPlaceholderString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"rwx_initWithString:")];
        
        [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasSuffix:) replaceMethod:NSSelectorFromString(@"rwx_hasSuffix:")];
        
        [self swizzlingInstance:objc_getClass("__NSCFConstantString") orginalMethod:@selector(hasPrefix:) replaceMethod:NSSelectorFromString(@"rwx_hasPrefix:")];
        
        [self swizzlingInstance:objc_getClass("NSPlaceholderMutableString") orginalMethod:@selector(initWithString:) replaceMethod:NSSelectorFromString(@"rwx_initWithString:")];
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

//  NSString (CrashProtector)
//  fix
@implementation NSString (Str)

- (instancetype)rwx_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self rwx_initWithString:aString];
}

- (BOOL)rwx_hasPrefix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self rwx_hasPrefix:str];
}

- (BOOL)rwx_hasSuffix:(NSString *)str
{
    if(nil == str){
        NSLog(@"need log msg");
        return NO;
    }
    return [self rwx_hasSuffix:str];
}

@end

//-----------------------------------------------------------------------------------------------------------------------------
//  NSMutableString (CrashProtector)
//  fix
@implementation NSMutableString (Str)

- (instancetype)rwx_initWithString:(NSString *)aString
{
    if(nil == aString){
        NSLog(@"need log msg");
        return nil;
    }
    return [self rwx_initWithString:aString];
}

@end

