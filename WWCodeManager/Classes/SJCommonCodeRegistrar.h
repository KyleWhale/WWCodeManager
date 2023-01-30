//
//  SJCommonCodeRegistrar.h
//  SJCommonCodeProject
//
//  Created by admin on 2017/12/5.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJCommonCodeAppState) {
    SJCommonCodeAppState_Active,
    SJCommonCodeAppState_Inactive,
    SJCommonCodeAppState_Background, // 从前台进入后台
};

@interface SJCommonCodeRegistrar : NSObject

@property (nonatomic, readonly) SJCommonCodeAppState state;

@property (nonatomic, copy, nullable) void(^willResignActive)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^willEnterForeground)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^didEnterBackground)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^willTerminate)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(SJCommonCodeRegistrar *registrar);

@property (nonatomic, copy, nullable) void(^audioSessionInterruption)(SJCommonCodeRegistrar *registrar);

@end

NS_ASSUME_NONNULL_END
