//
//  SJBaseCommonCodeConst.h
//  Pods
//
//  Created by admin on 2019/8/6.
//

#import <Foundation/Foundation.h>

/**
 用于记录常量和一些未来可能提供的通知.
 */

NS_ASSUME_NONNULL_BEGIN

extern NSInteger const SJBFCodeViewTag;
extern NSInteger const SJPresentViewTag;


@interface SJBFCodeZIndexes : NSObject
+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic) NSInteger textPopupViewZIndex;
@property (nonatomic) NSInteger promptingPopupViewZIndex;
@property (nonatomic) NSInteger controlLayerViewZIndex;
@property (nonatomic) NSInteger danmakuViewZIndex;
@property (nonatomic) NSInteger placeholderImageViewZIndex;
@property (nonatomic) NSInteger watermarkViewZIndex;
@property (nonatomic) NSInteger subtitleViewZIndex;
@property (nonatomic) NSInteger playbackViewZIndex;
@end

// - Playback Notifications -


extern NSNotificationName const SJCommonCodeAssetStatusDidChangeNotification;
extern NSNotificationName const SJCommonCodeDefinitionSwitchStatusDidChangeNotification;

extern NSNotificationName const SJCommonCodeResourceWillChangeNotification;
extern NSNotificationName const SJCommonCodeResourceDidChangeNotification;

extern NSNotificationName const SJCommonCodeApplicationDidEnterBackgroundNotification;
extern NSNotificationName const SJCommonCodeApplicationWillEnterForegroundNotification;
extern NSNotificationName const SJCommonCodeApplicationWillTerminateNotification;

extern NSNotificationName const SJCommonCodePlaybackControllerWillDeallocateNotification; ///< 注意: 发送对象变为了`SJMTPlaybackController`(目前只此一个, 其他都为player对象)

extern NSNotificationName const SJCommonCodePlaybackTimeControlStatusDidChangeNotification;
extern NSNotificationName const SJCommonCodePictureInPictureStatusDidChangeNotification;
extern NSNotificationName const SJCommonCodePlaybackDidFinishNotification;         // 播放完毕后发出的通知
extern NSNotificationName const SJCommonCodePlaybackDidReplayNotification;         // 执行replay发出的通知
extern NSNotificationName const SJCommonCodePlaybackWillStopNotification;          // 执行stop前发出的通知
extern NSNotificationName const SJCommonCodePlaybackDidStopNotification;           // 执行stop后发出的通知
extern NSNotificationName const SJCommonCodePlaybackWillRefreshNotification;       // 执行refresh前发出的通知
extern NSNotificationName const SJCommonCodePlaybackDidRefreshNotification;        // 执行refresh后发出的通知
extern NSNotificationName const SJCommonCodePlaybackWillSeekNotification;          // 执行seek前发出的通知
extern NSNotificationName const SJCommonCodePlaybackDidSeekNotification;           // 执行seek后发出的通知

extern NSNotificationName const SJCommonCodeCurrentTimeDidChangeNotification;
extern NSNotificationName const SJCommonCodeDurationDidChangeNotification;
extern NSNotificationName const SJCommonCodePlayableDurationDidChangeNotification;
extern NSNotificationName const SJCommonCodePresentationSizeDidChangeNotification;
extern NSNotificationName const SJCommonCodePlaybackTypeDidChangeNotification;

extern NSNotificationName const SJCommonCodeRateDidChangeNotification;
extern NSNotificationName const SJCommonCodeMutedDidChangeNotification;
extern NSNotificationName const SJCommonCodeVolumeDidChangeNotification;
extern NSNotificationName const SJCommonCodeScreenLockStateDidChangeNotification;

extern NSString *const SJCommonCodeNotificationUserInfoKeySeekTime;
NS_ASSUME_NONNULL_END
