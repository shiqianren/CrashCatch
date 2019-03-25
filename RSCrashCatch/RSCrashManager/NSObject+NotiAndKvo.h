//
//  NSObject+NotiAndKvo.h
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/25.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (NotiAndKvo)

+ (void)openNotiAndKvoCP;
+ (BOOL)swizzlingInstanceMethod:(SEL _Nullable )originalSelector  replaceMethod:(SEL _Nullable )replaceSelector;

@end
//-----------------------------------------------------------------------------------------------------------------------------
//KVOProxy
@class CPKVOInfo;
@interface KVOProxy : NSObject

-(BOOL)addKVOinfo:(id _Nullable )object info:(CPKVOInfo *_Nullable)info;
-(void)removeKVOinfo:(id _Nullable )object keyPath:(NSString *_Nullable)keyPath block:(void(^_Nullable)(void)) block;
-(void)removeAllObserve;
@end

typedef void (^CPKVONotificationBlock)(id _Nullable observer, id _Nullable object, NSDictionary<NSKeyValueChangeKey, id> * _Nullable change);

//-----------------------------------------------------------------------------------------------------------------------------
//CPKVOInfo
@interface CPKVOInfo : NSObject

- (instancetype _Nullable )initWithKeyPath:(NSString *_Nullable)keyPath options:(NSKeyValueObservingOptions)options context:(void *_Nullable)context;

@end
NS_ASSUME_NONNULL_END
