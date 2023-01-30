//
//  SJCommonCodePlaybackController.h
//  Project
//
//  Created by admin on 2018/8/10.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJMTPlaybackProtocol_h
#define SJMTPlaybackProtocol_h
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SJCommonCodePlayStatusDefines.h"
#import "SJPictureInPictureControllerDefines.h"

@protocol SJCommonCodePlaybackControllerDelegate, SJMTModelProtocol;

typedef AVLayerVideoGravity SJSPGravity;

typedef struct {
    BOOL isSeeking;
    CMTime time;
} SJSeekingInfo;

NS_ASSUME_NONNULL_BEGIN
@protocol SJCommonCodePlaybackController<NSObject>
@required
@property (nonatomic) NSTimeInterval periodicTimeInterval; // default value is 0.5
@property (nonatomic) NSTimeInterval minBufferedDuration; // default value is 8.0
@property (nonatomic, strong, readonly, nullable) NSError *error;
@property (nonatomic, weak, nullable) id<SJCommonCodePlaybackControllerDelegate> delegate;

@property (nonatomic, readonly) SJPlaybackType playbackType;
@property (nonatomic, strong, readonly) __kindof UIView *codeView;
@property (nonatomic, strong, nullable) id<SJMTModelProtocol> media;
@property (nonatomic, strong) SJSPGravity spGravity; // default value is AVLayerVideoGravityResizeAspect

// - status -
@property (nonatomic, readonly) SJAssetStatus assetStatus;
@property (nonatomic, readonly) SJPlaybackTimeControlStatus timeControlStatus;
@property (nonatomic, readonly, nullable) SJWaitingReason reasonForWaitingToPlay;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval playableDuration;
@property (nonatomic, readonly) NSTimeInterval durationWatched; // 已观看的时长
@property (nonatomic, readonly) CGSize presentationSize;
@property (nonatomic, readonly, getter=isReadyForDisplay) BOOL readyForDisplay;

@property (nonatomic) float volume;
@property (nonatomic) float rate;
@property (nonatomic, getter=isMuted) BOOL muted;

@property (nonatomic, readonly) BOOL isPlayed;                      ///< 当前media是否调用过play
@property (nonatomic, readonly, getter=isReplayed) BOOL replayed;   ///< 当前media是否调用过replay
@property (nonatomic, readonly) BOOL isPlaybackFinished;                        ///< 播放结束
@property (nonatomic, readonly, nullable) SJFinishedReason finishedReason;      ///< 播放结束的reason
- (void)prepareToPlay;
- (void)replay;
- (void)refresh;
- (void)play;
@property (nonatomic) BOOL pauseWhenAppDidEnterBackground;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ __nullable)(BOOL))completionHandler;
- (nullable UIImage *)screenshot;
- (void)switchVideoDefinition:(id<SJMTModelProtocol>)media;

- (BOOL)isPictureInPictureSupported API_AVAILABLE(ios(14.0));
@property (nonatomic) BOOL requiresLinearPlaybackInPictureInPicture API_AVAILABLE(ios(14.0));
@property (nonatomic) BOOL canStartPictureInPictureAutomaticallyFromInline API_AVAILABLE(ios(14.2));
@property (nonatomic, readonly) SJPictureInPictureStatus pictureInPictureStatus API_AVAILABLE(ios(14.0));
@property (nonatomic, copy, nullable) void(^restoreUserInterfaceForPictureInPictureStop)(id<SJCommonCodePlaybackController> controller, void(^completionHandler)(BOOL restored));
- (void)startPictureInPicture API_AVAILABLE(ios(14.0));
- (void)stopPictureInPicture API_AVAILABLE(ios(14.0));
- (void)cancelPictureInPicture API_AVAILABLE(ios(14.0));
@end

/// screenshot`
@protocol SJMTPlaybackScreenshotController
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(id<SJCommonCodePlaybackController> controller, UIImage * __nullable image, NSError *__nullable error))block;
@end


/// export
@protocol SJMTPlaybackExportController
- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(id<SJCommonCodePlaybackController> controller, float progress))progress
                 completion:(void(^)(id<SJCommonCodePlaybackController> controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completion
                    failure:(void(^)(id<SJCommonCodePlaybackController> controller, NSError * __nullable error))failure;

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(id<SJCommonCodePlaybackController> controller, float progress))progressBlock
                      completion:(void(^)(id<SJCommonCodePlaybackController> controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(id<SJCommonCodePlaybackController> controller, NSError *error))failure;

- (void)cancelExportOperation;
- (void)cancelGenerateGIFOperation;
@end


/// delegate
@protocol SJCommonCodePlaybackControllerDelegate<NSObject>

@optional
#pragma mark -
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller assetStatusDidChange:(SJAssetStatus)status;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller timeControlStatusDidChange:(SJPlaybackTimeControlStatus)status;
#pragma mark -


// - new -
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller volumeDidChange:(float)volume;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller rateDidChange:(float)rate;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller mutedDidChange:(BOOL)isMuted;

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playbackDidFinish:(SJFinishedReason)reason;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller durationDidChange:(NSTimeInterval)duration;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playbackTypeDidChange:(SJPlaybackType)playbackType;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration;
- (void)playbackControllerIsReadyForDisplay:(id<SJCommonCodePlaybackController>)controller;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMTModelProtocol>)media;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller didReplay:(id<SJMTModelProtocol>)media;

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0));

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller willSeekToTime:(CMTime)time;
- (void)playbackController:(id<SJCommonCodePlaybackController>)controller didSeekToTime:(CMTime)time;

- (void)applicationWillEnterForegroundWithPlaybackController:(id<SJCommonCodePlaybackController>)controller;
- (void)applicationDidBecomeActiveWithPlaybackController:(id<SJCommonCodePlaybackController>)controller;
- (void)applicationWillResignActiveWithPlaybackController:(id<SJCommonCodePlaybackController>)controller;
- (void)applicationDidEnterBackgroundWithPlaybackController:(id<SJCommonCodePlaybackController>)controller;
@end


/// media
@protocol SJMTModelProtocol
/// played by URL
@property (nonatomic, strong, nullable) NSURL *mtSource;

/// 开始播放的位置, 单位秒
@property (nonatomic) NSTimeInterval startPosition;

/// 试用结束的位置, 单位秒
@property (nonatomic) NSTimeInterval trialEndPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJMTPlaybackProtocol_h */
