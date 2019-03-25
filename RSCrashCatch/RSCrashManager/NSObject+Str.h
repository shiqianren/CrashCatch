//
//  NSObject+Str.h
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Str)
+ (void)openStrCP;
+ (BOOL)swizzlingInstanceMethod:(SEL _Nullable )originalSelector  replaceMethod:(SEL _Nullable )replaceSelector;
@end

// NSString
@interface NSString (Str)

@end

//-----------------------------------------------------------------------------------------------------------------------------
// NSMutableString
@interface NSMutableString (Str)

@end

NS_ASSUME_NONNULL_END
