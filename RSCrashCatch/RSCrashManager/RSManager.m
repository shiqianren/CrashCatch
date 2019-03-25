//
//  RSManager.m
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import "RSManager.h"

@implementation RSCatchConfig

- (instancetype)initDefault{
    if (self = [super init]) {
        self.isDebug = NO;
        self.openLog = NO;
        self.style = CrashProtectorAll;
    }
    return self;
}

@end

@implementation RSManager
{
    RSCatchConfig *configs;
}

+ (instancetype)instance{
    static RSManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[RSManager alloc] init];
        }
    });
    return _instance;
}
- (void)initWithConfig:(RSCatchConfig *)config{
    configs = config?:[[RSCatchConfig alloc] initDefault];
}
- (void)setLog:(Boolean)isOpen{
    
}
- (void)start{
    
}
- (void)stop{
    
}

@end
