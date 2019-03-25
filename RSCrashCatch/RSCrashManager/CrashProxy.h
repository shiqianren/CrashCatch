//
//  CrashProxy.h
//  RSCrashCatch
//
//  Created by QFMac-02 on 2019/3/22.
//  Copyright © 2019 shiqianren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashProxy : NSObject


@property (nonatomic ,copy) NSString *_Nullable crashMsg;;

- (void)getCrashMsg;

@end

NS_ASSUME_NONNULL_END
