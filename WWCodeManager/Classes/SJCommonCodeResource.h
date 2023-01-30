//
//  SJCommonCodeResource.h
//  SJCommonCodeProject
//
//  Created by admin on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayModel.h"
#import "SJCommonCodePlaybackControllerDefines.h"

@protocol SJCommonCodeResourceObserver;

NS_ASSUME_NONNULL_BEGIN

@interface SJCommonCodeResource : NSObject<SJMTModelProtocol>
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition;
- (nullable instancetype)initWithSource:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithSource:(NSURL *)URL;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;

@property (nonatomic, strong, null_resettable) SJPlayModel *playModel;
- (id<SJCommonCodeResourceObserver>)getObserver;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@property (nonatomic) BOOL isSpecial;
@end


@protocol SJCommonCodeResourceObserver <NSObject>
@property (nonatomic, copy, nullable) void(^playModelDidChangeExeBlock)(SJCommonCodeResource *asset);
@end
NS_ASSUME_NONNULL_END
