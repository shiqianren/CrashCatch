//
//  NSObject+Arr.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "NSObject+Arr.h"
#import "CrashProxy.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@implementation NSObject (Arr)

+ (void)openArrCP{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzlingInstance:objc_getClass("__NSPlaceholderArray") orginalMethod:@selector(initWithObjects:count:) replaceMethod:NSSelectorFromString(@"rwx_initWithObjects:count:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"rwx_objectAtIndex:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayI") orginalMethod:@selector(objectAtIndexedSubscript:) replaceMethod:NSSelectorFromString(@"rwx_objectAtIndexedSubscript:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(addObject:) replaceMethod:NSSelectorFromString(@"rwx_addObject:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(insertObject:atIndex:) replaceMethod:NSSelectorFromString(@"rwx_insertObject:atIndex:")];
        
        [self swizzlingInstance:objc_getClass("__NSArrayM") orginalMethod:@selector(objectAtIndex:) replaceMethod:NSSelectorFromString(@"rwx_objectAtIndex:")];
    });
}

+ (void)load{
//    [self openArrCP];
}

- (void)crashMsg:(NSString*)errorMsg{
    CrashProxy * crashProxy = [CrashProxy new];
    [crashProxy setCrashMsg:[NSString stringWithFormat:@"CrashProtector: [%@ %p %@]:",NSStringFromClass([self class]),self,errorMsg]];
}

+ (BOOL)swizzlingInstanceMethod:(SEL)originalSelector replaceMethod:(SEL)replaceSelector{
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
//  NSArray (CrashProtector)
//  fix
@implementation NSArray(Arr)
- (instancetype)rwx_initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt
{
    id safeObjects[cnt];
    NSUInteger j = 0;
    for (NSUInteger i = 0; i < cnt ; i++) {
        id obj = objects[i];
        if ( !obj) {
//            NSLog(@"need log msg");
            [self crashMsg:@"initWithObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)cnt"];
            continue;
        }
        safeObjects[j] = obj;
        j++;
    }
    return [self rwx_initWithObjects:safeObjects count:j];
}

- (id)rwx_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
//        NSLog(@"need log msg");
        [self crashMsg:@"objectAtIndex:(NSUInteger)index"];
        return nil;
    }
    return [self rwx_objectAtIndex:index];
}

- (id)rwx_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx >= self.count) {
//        NSLog(@"need log msg");
        [self crashMsg:@"objectAtIndexedSubscript:(NSUInteger)idx"];
        return nil;
    }
    return [self rwx_objectAtIndexedSubscript:idx];
}

@end

//  NSMutableArray (CrashProtector)
//  fix
@implementation NSMutableArray (Arr)

- (void)rwx_addObject:(id)anObject
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self rwx_addObject:anObject];
}

- (void)rwx_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if(nil == anObject){
        NSLog(@"need log msg");
        return ;
    }
    [self rwx_insertObject:anObject atIndex:index];
}

- (id)rwx_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        NSLog(@"need log msg");
        return nil;
    }
    return [self rwx_objectAtIndex:index];
}


@end
