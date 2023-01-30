//
//  SJCommonCodeResource+SJResourcePlaybackAdd.h
//  Project
//
//  Created by admin on 2018/8/12.
//  Copyright © 2018 changsanjiang. All rights reserved.
//

#import "SJCommonCodeResource.h"
#import <AVFoundation/AVFoundation.h>
#import "SJPlayModel.h"
#import "SJCommonCodePlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeResource (SJResourcePlaybackAdd)
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                               playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVAsset:(__kindof AVAsset *)asset
                           startPosition:(NSTimeInterval)startPosition
                               playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                    playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVPlayerItem:(AVPlayerItem *)playerItem
                                startPosition:(NSTimeInterval)startPosition
                                    playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                                playModel:(__kindof SJPlayModel *)playModel;
- (nullable instancetype)initWithAVPlayer:(AVPlayer *)player
                            startPosition:(NSTimeInterval)startPosition
                                playModel:(__kindof SJPlayModel *)playModel;

@property (nonatomic, strong, nullable) __kindof AVAsset *avAsset;
@property (nonatomic, strong, nullable) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong, nullable) AVPlayer *avPlayer;

- (nullable instancetype)initWithOtherAsset:(SJCommonCodeResource *)otherAsset
                                  playModel:(nullable __kindof SJPlayModel *)playModel;

@property (nonatomic, strong, readonly, nullable) SJCommonCodeResource *original;
- (nullable SJCommonCodeResource *)originAsset __deprecated_msg("ues `original`");
@end
NS_ASSUME_NONNULL_END
