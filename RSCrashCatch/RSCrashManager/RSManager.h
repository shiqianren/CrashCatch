//
//  RSManager.h
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, CrashCatchStyle){
    CrashProtectorNone = 0,
    CrashProtectorAll ,
    CrashProtectorUnrecognizedSelector,
    CrashProtectorKVO ,
    CrashProtectorNotification ,
    CrashProtectorTimer ,
    CrashProtectorContainer ,
    CrashProtectorString ,
};
NS_ASSUME_NONNULL_BEGIN
@interface RSCatchConfig : NSObject
@property(nonatomic,assign) Boolean             openLog;
@property(nonatomic,assign) Boolean             isDebug;
@property(nonatomic,assign) CrashCatchStyle style;

-(instancetype)initDefault;

@end

@interface RSManager : NSObject

+(instancetype)instance;

-(void)initWithConfig:(RSCatchConfig *) config;

-(void)start;
-(void)stop;
-(void)setLog:(Boolean) isOpen;

@end

NS_ASSUME_NONNULL_END
