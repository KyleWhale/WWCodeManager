//
//  SJBaseCommonCodeConst.m
//  Pods
//
//  Created by admin on 2019/8/6.
//

#import "SJBaseCommonCodeConst.h"
#import "SJCommonCodePlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN

NSInteger const SJBFCodeViewTag = 0xFFFFFFF0;
NSInteger const SJPresentViewTag = 0xFFFFFFF1;

@implementation SJBFCodeZIndexes
+ (instancetype)shared {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] _init];
    });
    return instance;
}

- (instancetype)_init {
    self = [super init];
    if ( self ) {
        _textPopupViewZIndex = -10;
        _promptingPopupViewZIndex = -20;
        _controlLayerViewZIndex = -30;
        _danmakuViewZIndex = -40;
        _placeholderImageViewZIndex = -50;
        _watermarkViewZIndex = -60;
        _subtitleViewZIndex = -70;
        _playbackViewZIndex = -80;
    }
    return self;
}
@end

///
/// assetStatus 改变的通知
///
NSNotificationName const SJCommonCodeAssetStatusDidChangeNotification = @"SJCommonCodeAssetStatusDidChangeNotification";

///
/// 切换清晰度状态 改变的通知
///
NSNotificationName const SJCommonCodeDefinitionSwitchStatusDidChangeNotification = @"SJCommonCodeDefinitionSwitchStatusDidChangeNotification";

///
/// 播放资源将要改变前发出的通知
///
NSNotificationName const SJCommonCodeResourceWillChangeNotification = @"SJCommonCodeResourceWillChangeNotification";
///
/// 播放资源改变后发出的通知
///
NSNotificationName const SJCommonCodeResourceDidChangeNotification = @"SJCommonCodeResourceDidChangeNotification";




///
/// 播放器收到App进入后台的通知后发出的通知
///
NSNotificationName const SJCommonCodeApplicationDidEnterBackgroundNotification = @"SJCommonCodeApplicationDidEnterBackgroundNotification";
///
/// 播放器收到App进入前台的通知后发出的通知
///
NSNotificationName const SJCommonCodeApplicationWillEnterForegroundNotification = @"SJCommonCodeApplicationWillEnterForegroundNotification";
///
/// 播放器收到App将要关闭的通知后发出的通知
///
NSNotificationName const SJCommonCodeApplicationWillTerminateNotification = @"SJCommonCodeApplicationWillTerminateNotification";

///
/// 播放器的playbackController将要进行销毁前的通知
///
NSNotificationName const SJCommonCodePlaybackControllerWillDeallocateNotification = @"SJCommonCodePlaybackControllerWillDeallocateNotification"; ///< 注意: object 为 SJMTPlaybackController 的对象


///
/// timeControlStatus 改变的通知
///
NSNotificationName const SJCommonCodePlaybackTimeControlStatusDidChangeNotification = @"SJCommonCodePlaybackTimeControlStatusDidChangeNotification";
///
/// picture in picture status 改变的通知
///
NSNotificationName const SJCommonCodePictureInPictureStatusDidChangeNotification = @"SJCommonCodePictureInPictureStatusDidChangeNotification";
///
/// 播放完毕后发出的通知
///
NSNotificationName const SJCommonCodePlaybackDidFinishNotification = @"SJCommonCodePlaybackDidFinishNotification";

///
/// 执行replay发出的通知
///
NSNotificationName const SJCommonCodePlaybackDidReplayNotification = @"SJCommonCodePlaybackDidReplayNotification";
///
/// 执行stop前发出的通知
///
NSNotificationName const SJCommonCodePlaybackWillStopNotification = @"SJCommonCodePlaybackWillStopNotification";
///
/// 执行stop后发出的通知
///
NSNotificationName const SJCommonCodePlaybackDidStopNotification = @"SJCommonCodePlaybackDidStopNotification";
///
/// 执行refresh前发出的通知
///
NSNotificationName const SJCommonCodePlaybackWillRefreshNotification = @"SJCommonCodePlaybackWillRefreshNotification";
///
/// 执行refresh后发出的通知
///
NSNotificationName const SJCommonCodePlaybackDidRefreshNotification = @"SJCommonCodePlaybackDidRefreshNotification";
///
/// 执行seek前发出的通知
///
NSNotificationName const SJCommonCodePlaybackWillSeekNotification = @"SJCommonCodePlaybackWillSeekNotification";
///
/// 执行seek后发出的通知
///
NSNotificationName const SJCommonCodePlaybackDidSeekNotification = @"SJCommonCodePlaybackDidSeekNotification";



///
/// 当前播放时间 改变的通知
///
NSNotificationName const SJCommonCodeCurrentTimeDidChangeNotification = @"SJCommonCodeCurrentTimeDidChangeNotification";

///
/// 获取到播放时长的通知
///
NSNotificationName const SJCommonCodeDurationDidChangeNotification = @"SJCommonCodeDurationDidChangeNotification";

///
/// 缓冲时长 改变的通知
///
NSNotificationName const SJCommonCodePlayableDurationDidChangeNotification = @"SJCommonCodePlayableDurationDidChangeNotification";

///
/// 获取到视频宽高的通知
///
NSNotificationName const SJCommonCodePresentationSizeDidChangeNotification = @"SJCommonCodePresentationSizeDidChangeNotification";

///
/// 获取到播放类型的通知
///
NSNotificationName const SJCommonCodePlaybackTypeDidChangeNotification = @"SJCommonCodePlaybackTypeDidChangeNotification";

///
/// 锁屏状态 改变的通知
///
NSNotificationName const SJCommonCodeScreenLockStateDidChangeNotification = @"SJCommonCodeScreenLockStateDidChangeNotification";

///
/// 静音状态 改变的通知
///
NSNotificationName const SJCommonCodeMutedDidChangeNotification = @"SJCommonCodeMutedDidChangeNotification";

///
/// 音量 改变的通知
///
NSNotificationName const SJCommonCodeVolumeDidChangeNotification = @"SJCommonCodeVolumeDidChangeNotification";

///
/// 调速 改变的通知
///
NSNotificationName const SJCommonCodeRateDidChangeNotification = @"SJCommonCodeRateDidChangeNotification";


SJWaitingReason const SJWaitingToMinimizeStallsReason = @"AVPlayerWaitingToMinimizeStallsReason";
SJWaitingReason const SJWaitingWhileEvaluatingBufferingRateReason = @"AVPlayerWaitingWhileEvaluatingBufferingRateReason";
SJWaitingReason const SJWaitingWithNoAssetToPlayReason = @"AVPlayerWaitingWithNoItemToPlayReason";

SJFinishedReason const SJFinishedReasonToEndTimePosition = @"SJFinishedReasonToEndTimePosition";
SJFinishedReason const SJFinishedReasonToTrialEndPosition = @"SJFinishedReasonToTrialEndPosition";

NSString *const SJCommonCodeNotificationUserInfoKeySeekTime = @"time";
NS_ASSUME_NONNULL_END
