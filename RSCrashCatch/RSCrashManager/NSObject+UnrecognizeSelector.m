//
//  NSObject+UnrecognizeSelector.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "NSObject+UnrecognizeSelector.h"
#import "CrashProxy.h"
#import <objc/runtime.h>
@implementation NSObject (UnrecognizeSelector)

+ (void)openCP{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}

+ (void)load{
    [self openCP];
}


+ (BOOL)swizzlingInstanceMethod:(SEL)originalSelector replaceMethod:(SEL)replaceSelector{
    return true;
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-protocol-method-implementation"
- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([NSStringFromClass([self class]) hasPrefix:@"_"] || [self isKindOfClass:NSClassFromString(@"UITextInputController")] || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"] || [methodName isEqualToString:@"dealloc"]) {
        
        return nil;
    }
    CrashProxy * crashProxy = [CrashProxy new];
    crashProxy.crashMsg =[NSString stringWithFormat:@"CrashProtector: [%@ %p %@]: unrecognized selector sent to instance",NSStringFromClass([self class]),self,NSStringFromSelector(aSelector)];
    
    class_addMethod([CrashProxy class], aSelector, [crashProxy methodForSelector:@selector(getCrashMsg)], "V@:");
    
    return crashProxy;
}
@end
