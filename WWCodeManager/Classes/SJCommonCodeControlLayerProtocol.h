//
//  SJCommonCodeControlLayerProtocol.h
//  Project
//
//  Created by admin on 2018/6/1.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJCommonCodeControlLayerProtocol_h
#define SJCommonCodeControlLayerProtocol_h
#import <UIKit/UIKit.h>
#import "SJReachabilityDefines.h"
#import "SJCommonCodePlayStatusDefines.h"
#import "SJCommonCodePlaybackControllerDefines.h"
#import "SJGestureControllerDefines.h"

@protocol SJPlaybackInfoDelegate,
SJNetworkStatusControlDelegate,
SJLockScreenStateControlDelegate,
SJAppActivityControlDelegate,
SJVolumeBrightnessRateControlDelegate,
SJGestureControllerDelegate,
SJRotationControlDelegate,
SJFitOnScreenControlDelegate,
SJSwitchVideoDefinitionControlDelegate,
SJPlaybackControlDelegate;

@class SJBaseCommonCode, SJCommonCodeResource;



@protocol SJCommonCodeControlLayerDataSource <NSObject>
@required
/// Please return to the control view of the control layer, which will be added to the player view.
/// 请返回控制层的根视图
/// 这个视图将会添加的播放器中
- (UIView *)controlView;

@optional
/// This method will be called When installed control view of control layer to the video player.
/// 当安装好控制层后, 会回调这个方法
- (void)installedControlViewToCommonCode:(__kindof SJBaseCommonCode *)commonCode;
@end


@protocol SJCommonCodeControlLayerDelegate <
    SJPlaybackInfoDelegate, 
    SJRotationControlDelegate,
    SJGestureControllerDelegate,
    SJNetworkStatusControlDelegate,
    SJVolumeBrightnessRateControlDelegate,
    SJLockScreenStateControlDelegate,
    SJAppActivityControlDelegate,
    SJFitOnScreenControlDelegate,
    SJSwitchVideoDefinitionControlDelegate,
    SJPlaybackControlDelegate
>
@optional
/// This method will be called when the control layer needs to be appear.
/// You should do some appear work here.
/// 控制层需要显示. 你应该在这里做一些显示的工作
- (void)controlLayerNeedAppear:(__kindof SJBaseCommonCode *)commonCode;

/// This method will be called when the control layer needs to be disappear.
/// You should do some disappear work here.
/// 控制层需要隐藏. 你应该在这个做一些隐藏的工作
- (void)controlLayerNeedDisappear:(__kindof SJBaseCommonCode *)commonCode;

/// Asks the delegate if the control layer can automatically disappear.
/// 控制层是否可以自动隐藏
- (BOOL)controlLayerOfCommonCodeCanAutomaticallyDisappear:(__kindof SJBaseCommonCode *)commonCode;

/// Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将出现时会回调这个方法
- (void)commonCodeWillAppearInScrollView:(__kindof SJBaseCommonCode *)commonCode;

/// Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
/// 当滚动scrollView时, 播放器即将消失时会回调这个方法
- (void)commonCodeWillDisappearInScrollView:(__kindof SJBaseCommonCode *)commonCode;
@end


@protocol SJPlaybackControlDelegate <NSObject>
@optional
- (BOOL)canPerformPlayForCommonCode:(__kindof SJBaseCommonCode *)commonCode;
- (BOOL)canPerformPauseForCommonCode:(__kindof SJBaseCommonCode *)commonCode;
- (BOOL)canPerformStopForCommonCode:(__kindof SJBaseCommonCode *)commonCode;
@end



@protocol SJPlaybackInfoDelegate <NSObject>
@optional

/// When the player is prepare to play a new asset, this method will be called.
/// 当播放器准备播放一个新的资源时, 会回调这个方法
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode prepareToPlay:(SJCommonCodeResource *)asset;

///
/// 播放状态改变后的回调
///
///     以下状态发生变更时将会触发该回调
///     1.  timeControlStatus
///     2.  assetStatus
///     3.  播放完毕
///
- (void)commonCodePlaybackStatusDidChange:(__kindof SJBaseCommonCode *)commonCode;

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0));

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode durationDidChange:(NSTimeInterval)duration;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode playableDurationDidChange:(NSTimeInterval)duration;

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode playbackTypeDidChange:(SJPlaybackType)playbackType;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode presentationSizeDidChange:(CGSize)size;
@end



@protocol SJVolumeBrightnessRateControlDelegate <NSObject>
@optional
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode muteChanged:(BOOL)mute;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode volumeChanged:(float)volume;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode brightnessChanged:(float)brightness;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode rateChanged:(float)rate;
@end


@protocol SJRotationControlDelegate <NSObject>
@optional
/// Whether trigger rotation of video player
- (BOOL)canTriggerRotationOfCommonCode:(__kindof SJBaseCommonCode *)commonCode;

/// Call it when player will rotate, `isFull` if YES, then full screen.
/// 当播放器将要旋转的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode willRotateView:(BOOL)isFull;

/// When rotated player, this method will be called.
/// 当播放器旋转完成的时候, 会回调这个方法
/// isFull 标识是否是全屏
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode didEndRotation:(BOOL)isFull;

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode onRotationTransitioningChanged:(BOOL)isTransitioning;
@end


/// v1.3.1 新增
/// 全屏但不旋转
@protocol SJFitOnScreenControlDelegate <NSObject>
@optional
///  When `fitOnScreen` of player will change, this method will be called;
/// 当播放器即将全屏(但不旋转)时, 这个方法将会被调用
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode willFitOnScreen:(BOOL)isFitOnScreen;
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode didCompleteFitOnScreen:(BOOL)isFitOnScreen;
@end



@protocol SJGestureControllerDelegate <NSObject>
@optional
/// Asks the delegate if gesture should trigger in the video player.
/// 是否可以触发某个手势
- (BOOL)commonCode:(__kindof SJBaseCommonCode *)commonCode gestureRecognizerShouldTrigger:(SJBFCodeGestureType)type location:(CGPoint)location;

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode panGestureTriggeredInTheHorizontalDirection:(SJPanGestureRecognizerState)state progressTime:(NSTimeInterval)progressTime;

- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode longPressGestureStateDidChange:(SJLongPressGestureRecognizerState)state;
@end



@protocol SJNetworkStatusControlDelegate <NSObject>
@optional
/// 网络状态变更
/// 当网络状态变更时, 会回调这个方法
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode reachabilityChanged:(SJNetworkStatus)status;
@end



@protocol SJLockScreenStateControlDelegate <NSObject>
@optional
/// This Tap gesture triggered when player locked screen.
/// If player locked(commonCode.lockedScreen == YES), When the user tapped on the player this method will be called.
/// 这是一个只有在播放器锁屏状态下, 才会回调的方法
/// 当播放器锁屏后, 用户每次点击都会回调这个方法
- (void)tappedPlayerOnTheLockedState:(__kindof SJBaseCommonCode *)commonCode;

/// Call it when set commonCode.lockedScreen == YES.
/// 当设置 commonCode.lockedScreen == YES 时, 这个方法将会调用
- (void)lockedCommonCode:(__kindof SJBaseCommonCode *)commonCode;

/// Call it when set commonCode.lockedScreen == NO.
/// 当设置 commonCode.lockedScreen == NO 时, 这个方法将会调用
- (void)unlockedCommonCode:(__kindof SJBaseCommonCode *)commonCode;
@end



@protocol SJSwitchVideoDefinitionControlDelegate <NSObject>
@optional
- (void)commonCode:(__kindof SJBaseCommonCode *)commonCode switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMTModelProtocol>)media;
@end



@protocol SJAppActivityControlDelegate <NSObject>
@optional
- (void)applicationWillEnterForegroundWithCommonCode:(__kindof SJBaseCommonCode *)commonCode;
- (void)applicationDidBecomeActiveWithCommonCode:(__kindof SJBaseCommonCode *)commonCode;
- (void)applicationWillResignActiveWithCommonCode:(__kindof SJBaseCommonCode *)commonCode;
- (void)applicationDidEnterBackgroundWithCommonCode:(__kindof SJBaseCommonCode *)commonCode;
@end
#endif /* SJCommonCodeControlLayerProtocol_h */
