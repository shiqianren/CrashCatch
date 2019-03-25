//
//  NSObject+NotiAndKvo.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/25.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "NSObject+NotiAndKvo.h"
#import <objc/runtime.h>
#import <pthread.h>
#import "RWXProxy.h"
#import "CrashProxy.h"

// fix "unrecognized selector" ,"KVC"
static void *NSObjectKVOProxyKey = &NSObjectKVOProxyKey;
@implementation NSObject (NotiAndKvo)

+ (void)openNotiAndKvoCP{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzlingInstance:objc_getClass("NSNotificationCenter") orginalMethod:NSSelectorFromString(@"addObserver:selector:name:object:") replaceMethod:NSSelectorFromString(@"rwx_addObserver:selector:name:object:")];
        
        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"dealloc") replaceMethod:NSSelectorFromString(@"rwx_dealloc")];
        
        //暂时注释kvo预防，该逻辑在 xcode9.2 真机测试会 crash
        
        //        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"addObserver:forKeyPath:options:context:") replaceMethod:NSSelectorFromString(@"rwx_addObserver:forKeyPath:options:context:")];
        //
        //        [self swizzlingInstance:self orginalMethod:NSSelectorFromString(@"removeObserver:forKeyPath:") replaceMethod:NSSelectorFromString(@"rwx_removeObserver:forKeyPath:")];
        
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


#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wobjc-protocol-method-implementation"
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *methodName = NSStringFromSelector(aSelector);
    if ([NSStringFromClass([self class]) hasPrefix:@"_"] || [self isKindOfClass:NSClassFromString(@"UITextInputController")] || [NSStringFromClass([self class]) hasPrefix:@"UIKeyboard"] || [methodName isEqualToString:@"dealloc"]) {
        
        return nil;
    }
    
    CrashProxy * crashProxy = [CrashProxy new];
    crashProxy.crashMsg =[NSString stringWithFormat:@"CrashProtector: [%@ %p %@]: unrecognized selector sent to instance",NSStringFromClass([self class]),self,NSStringFromSelector(aSelector)];
    class_addMethod([CrashProxy class], aSelector, [crashProxy methodForSelector:@selector(getCrashMsg)], "v@:");
    
    return crashProxy;
}
#pragma clang diagnostic pop


#pragma KVC Protect
-(void)setNilValueForKey:(NSString *)key
{
    NSLog(@"need log msg");
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"need log msg");
}

- (nullable id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"need log msg");
    return self;
}

#pragma NSNotification
-(void)rwx_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject
{
    [observer setIsNSNotification:YES];
    [self rwx_addObserver:observer selector:aSelector name:aName object:anObject];
}

-(void)rwx_dealloc
{
    if ([self isNSNotification]) {
        NSLog(@"[Notification] need log msg");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self rwx_dealloc];
}

static const char *isNSNotification = "isNSNotification";

-(void)setIsNSNotification:(BOOL)yesOrNo
{
    objc_setAssociatedObject(self, isNSNotification, @(yesOrNo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isNSNotification
{
    NSNumber *number = objc_getAssociatedObject(self, isNSNotification);;
    return  [number boolValue];
}

#pragma KVO
- (void)rwx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    CPKVOInfo * kvoInfo = [[CPKVOInfo alloc] initWithKeyPath:keyPath options:options context:context];
    __weak typeof(self) wkself = self;
    if([self.KVOProxy addKVOinfo:wkself info:kvoInfo]){
        [self rwx_addObserver:self.KVOProxy forKeyPath:keyPath options:options context:context];
    }else{
        NSLog(@"KVO is more");
    }
}

- (void)rwx_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    NSLog(@"rwx_removeObserver");
    [self.KVOProxy removeKVOinfo:self keyPath:keyPath block:^{
        [self rwx_removeObserver:observer forKeyPath:keyPath];
    }];
}

- (KVOProxy *)KVOProxy
{
    id proxy = objc_getAssociatedObject(self, NSObjectKVOProxyKey);
    
    if (nil == proxy) {
        proxy = [[KVOProxy alloc] init];
        self.KVOProxy = proxy;
    }
    
    return proxy;
}

- (void)setKVOProxy:(KVOProxy *)proxy
{
    objc_setAssociatedObject(self, NSObjectKVOProxyKey, proxy, OBJC_ASSOCIATION_ASSIGN);
}


@end
//  CPKVOInfo
@implementation CPKVOInfo{
@public
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    SEL _action;
    void *_context;
    CPKVONotificationBlock _block;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(nullable CPKVONotificationBlock)block
                         action:(nullable SEL)action
                        context:(nullable void *)context
{
    self = [super init];
    if (nil != self) {
        _block = [block copy];
        _keyPath = [keyPath copy];
        _options = options;
        _action = action;
        _context = context;
    }
    return self;
}

- (instancetype)initWithKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    return [self initWithKeyPath:keyPath options:options block:NULL action:NULL context:context];
}

@end
//  KVOProxy
//  fix
@implementation KVOProxy{
    pthread_mutex_t _mutex;
    NSMapTable<id, NSMutableSet<CPKVOInfo *> *> *_objectInfosMap;
}


- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        
        _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
        
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

-(BOOL)addKVOinfo:(id)object info:(CPKVOInfo *)info
{
    [self lock];
    
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block BOOL isHas = NO;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([[info valueForKey:@"_keyPath"] isEqualToString:[obj valueForKey:@"_keyPath"]]){
            *stop = YES;
            isHas = YES;
        }
    }];
    if(isHas) {
        [self unlock];
        return NO ;
    }
    if(nil == infos){
        infos = [NSMutableSet set];
        [_objectInfosMap setObject:infos forKey:object];
    }
    [infos addObject:info];
    [self unlock];
    
    return YES;
}

-(void)removeKVOinfo:(id)object keyPath:(NSString *)keyPath block:(void(^)(void)) block
{
    [self lock];
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    __block CPKVOInfo *info;
    [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
            info = (CPKVOInfo *)obj;
            *stop = YES;
        }
    }];
    
    if (nil != info) {
        [infos removeObject:info];
        block();
        if (0 == infos.count) {
            [_objectInfosMap removeObjectForKey:object];
        }
    }
    [self unlock];
}

-(void)removeAllObserve
{
    if (_objectInfosMap) {
        NSMapTable *objectInfoMaps = [_objectInfosMap copy];
        for (id object in objectInfoMaps) {
            
            NSSet *infos = [objectInfoMaps objectForKey:object];
            if(nil==infos || infos.count==0) continue;
            [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                CPKVOInfo *info = (CPKVOInfo *)obj;
                [object removeObserver:self forKeyPath:[info valueForKey:@"_keyPath"]];
            }];
        }
        [_objectInfosMap removeAllObjects];
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    NSLog(@"KVOProxy - observeValueForKeyPath :%@",change);
    __block CPKVOInfo *info ;
    {
        [self lock];
        NSSet *infos = [_objectInfosMap objectForKey:object];
        [infos enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([keyPath isEqualToString:[obj valueForKey:@"_keyPath"]]){
                info = (CPKVOInfo *)obj;
                *stop = YES;
            }
        }];
        [self unlock];
    }
    
    if (nil != info) {
        [object observeValueForKeyPath:keyPath ofObject:object change:change context:(__bridge void * _Nullable)([info valueForKey:@"_context"])];
    }
}

-(void)lock
{
    pthread_mutex_lock(&_mutex);
}

-(void)unlock
{
    pthread_mutex_unlock(&_mutex);
}

- (void)dealloc
{
    [self removeAllObserve];
    pthread_mutex_destroy(&_mutex);
    NSLog(@"KVOProxy dealloc");
}

@end
