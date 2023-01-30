//
//  SJPlaybackObservation.h
//  Pods
//
//  Created by admin on 2019/8/27.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVTime.h>
@class SJBaseCommonCode;

NS_ASSUME_NONNULL_BEGIN

@interface SJPlaybackObservation : NSObject
- (instancetype)initWithPlayer:(__kindof SJBaseCommonCode *)player;

///
/// 播放状态改变后的回调
///
///     该block集合里以下3种回调
///     1.  timeControlStatusDidChangeExeBlock(播放控制改变的时候)
///     2.  assetStatusDidChangeExeBlock(资源状态改变的时候)
///     3.  playbackDidFinishExeBlock(播放完毕的时候)
///
@property (nonatomic, copy, nullable) void(^playbackStatusDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 播放完毕的回调
///
@property (nonatomic, copy, nullable) void(^playbackDidFinishExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 资源状态改变的回调
///
@property (nonatomic, copy, nullable) void(^assetStatusDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 播放控制改变的回调
///
@property (nonatomic, copy, nullable) void(^timeControlStatusDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 画中画状态改变的回调
///
@property (nonatomic, copy, nullable) void(^pictureInPictureStatusDidChangeExeBlock)(__kindof SJBaseCommonCode *player) API_AVAILABLE(ios(14.0));

///
/// 调用seek之前的回调
///
@property (nonatomic, copy, nullable) void(^willSeekToTimeExeBlock)(__kindof SJBaseCommonCode *player, CMTime time);

///
/// 调用seek之后的回调
///
@property (nonatomic, copy, nullable) void(^didSeekToTimeExeBlock)(__kindof SJBaseCommonCode *player, CMTime time);

///
/// 调用了重播的回调
///
@property (nonatomic, copy, nullable) void(^didReplayExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 切换清晰度状态改变的回调
///
@property (nonatomic, copy, nullable) void(^definitionSwitchStatusDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 当前时间改变的回调
///
@property (nonatomic, copy, nullable) void(^currentTimeDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 播放时长改变的回调
///
@property (nonatomic, copy, nullable) void(^durationDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 缓冲时长改变的回调
///
@property (nonatomic, copy, nullable) void(^playableDurationDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 获取到 video presentation size 时的回调
///
@property (nonatomic, copy, nullable) void(^presentationSizeDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 获取到文件类型的回调
///
@property (nonatomic, copy, nullable) void(^playbackTypeDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 锁屏状态改变的回调
///
@property (nonatomic, copy, nullable) void(^screenLockStateDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 播放器的静音状态改变的回调
///
@property (nonatomic, copy, nullable) void(^mutedDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 播放器的声音改变的回调
///
@property (nonatomic, copy, nullable) void(^playerVolumeDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

///
/// 调速的回调
///
@property (nonatomic, copy, nullable) void(^rateDidChangeExeBlock)(__kindof SJBaseCommonCode *player);

@property (nonatomic, weak, readonly, nullable) __kindof SJBaseCommonCode *player;

///
/// 播放完毕的回调
///
///         现在不仅仅有播放至结束的位置了, 还会有播放至试看结束, 由于该属性仅能表示第一种情况, 故不推荐使用了.
///
@property (nonatomic, copy, nullable) void(^didPlayToEndTimeExeBlock)(__kindof SJBaseCommonCode *player) __deprecated_msg("use `playbackDidFinishExeBlock`");

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
