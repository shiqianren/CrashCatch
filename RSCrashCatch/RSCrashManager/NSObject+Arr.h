//
//  NSObject+Arr.h
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Arr)
+ (void)openArrCP;

+ (BOOL)swizzlingInstanceMethod:(SEL _Nullable )originalSelector  replaceMethod:(SEL _Nullable )replaceSelector;
@end
//NSAarry
@interface NSArray(Arr)
@end

@interface NSMutableArray(Arr)
@end


NS_ASSUME_NONNULL_END
