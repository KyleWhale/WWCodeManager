//
//  SJResourcePlaybackController.m
//  Pods
//
//  Created by admin on 2020/2/18.
//

#import "SJResourcePlaybackController.h"
#import "SJExecuteCodeLoader.h"
#import "SJExecuteCode.h"
#import "SJExecuteCodeLayerView.h"
#import "SJCommonCodeResource+SJResourcePlaybackAdd.h"
#import "AVAsset+SJResourceExport.h"
#import "SJResourceExternalController.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJResourcePlaybackController ()<SJPictureInPictureControllerDelegate>
@property (nonatomic, strong, nullable) SJResourceExternalController *pictureInPictureController API_AVAILABLE(ios(14.0));
// https://github.com/changsanjiang/SJCommonCode/issues/339
@property (nonatomic) BOOL needsToRefresh_fix339 API_AVAILABLE(ios(14.0));
@end

@implementation SJResourcePlaybackController
@dynamic currentPlayer;
@dynamic currentPlayerView;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_playbackTypeDidChange:) name:SJCodeShowPlaybackTypeDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_playerViewReadyForDisplay:) name:SJCodeShowViewReadyForDisplayNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_rateDidChange:) name:SJCodeShowRateDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_volumeDidChange:) name:SJCodeShowVolumeDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_mutedDidChange:) name:SJCodeShowMutedDidChangeNotification object:nil];
        if (@available(iOS 14.2, *)) {
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_av_assetStatusDidChange:) name:SJCodeShowAssetStatusDidChangeNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark -

- (void)playerWithMedia:(SJCommonCodeResource *)media completionHandler:(void (^)(id<SJCodeShow> _Nullable))completionHandler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SJExecuteCode *player = [SJExecuteCodeLoader loadPlayerForMedia:media];
        player.minBufferedDuration = self.minBufferedDuration;
        player.accurateSeeking = self.accurateSeeking;
        
        if ( (player.isPlayed && media.original == nil) || player.isPlaybackFinished ) {
            [player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ( completionHandler ) completionHandler(player);
                });
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( completionHandler ) completionHandler(player);
            });
        }
    });
}

- (UIView<SJCodeShowView> *)playerViewWithPlayer:(SJExecuteCode *)player {
    SJExecuteCodeLayerView *view = [SJExecuteCodeLayerView.alloc initWithFrame:CGRectZero];
    view.layer.player = player.avPlayer;
    return view;
}

- (void)receivedApplicationDidBecomeActiveNotification {
    if ( @available(iOS 14.0, *) ) {
        if ( _pictureInPictureController.isEnabled )
            return;
    }
    
    if ( @available(iOS 14.0, *) ) {
        if ( self.media.isSpecial ) {
            if ( self.pauseWhenAppDidEnterBackground ||
                 // fix: https://github.com/changsanjiang/SJCommonCode/issues/535
                 self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
                if ( self.timeControlStatus == SJPlaybackTimeControlStatusPaused ) {
                    self.needsToRefresh_fix339 = YES;
                    return;
                }
            }
        }
        
    }
    
    SJExecuteCodeLayerView *view = self.currentPlayerView;
    view.layer.player = self.currentPlayer.avPlayer;
    
    // fix: https://github.com/changsanjiang/SJCommonCode/issues/395
    if ( self.currentPlayerView.isReadyForDisplay ) {
        [self.currentPlayerView setScreenshot:nil];
    }
}
 
- (void)receivedApplicationDidEnterBackgroundNotification {
    if ( @available(iOS 14.0, *) ) {
        if ( _pictureInPictureController.isEnabled )
            return;
    }
    
    if ( self.pauseWhenAppDidEnterBackground ) {
        [self pause];
    }
    else {
        [self _removePlayerForLayerIfNeeded];
    }
}

- (void)receivedApplicationWillResignActiveNotification {
    if ( @available(iOS 14.0, *) ) {
        if ( _pictureInPictureController.isEnabled )
            return;
    }
    
    if ( self.pauseWhenAppDidEnterBackground && self.assetStatus == SJAssetStatusReadyToPlay /*fix #430 */ )
        [self.currentPlayerView setScreenshot:self.screenshot];
    
    // 修复 14.0 后台播放失效的问题
    if ( @available(iOS 14.0, *) ) {
        [self _removePlayerForLayerIfNeeded];
    }
}

- (void)replaceMediaForDefinitionMedia:(SJCommonCodeResource *)definitionMedia {
    if ( @available(iOS 14.0, *) ) {
        [self cancelPictureInPicture];
    }
    [SJExecuteCodeLoader clearPlayerForMedia:self.media];
    [super replaceMediaForDefinitionMedia:definitionMedia];
}

#pragma mark - PiP

- (BOOL)isPictureInPictureSupported API_AVAILABLE(ios(14.0)) {
    return SJResourceExternalController.isPictureInPictureSupported;
}

- (void)setRequiresLinearPlaybackInPictureInPicture:(BOOL)requiresLinearPlaybackInPictureInPicture API_AVAILABLE(ios(14.0)) {
    [super setRequiresLinearPlaybackInPictureInPicture:requiresLinearPlaybackInPictureInPicture];
    _pictureInPictureController.requiresLinearPlayback = requiresLinearPlaybackInPictureInPicture;
}

- (SJPictureInPictureStatus)pictureInPictureStatus API_AVAILABLE(ios(14.0)) {
    return _pictureInPictureController.status;
}

- (void)setCanStartPictureInPictureAutomaticallyFromInline:(BOOL)canStartPictureInPictureAutomaticallyFromInline API_AVAILABLE(ios(14.2)) {
    [super setCanStartPictureInPictureAutomaticallyFromInline:canStartPictureInPictureAutomaticallyFromInline];
    _pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = canStartPictureInPictureAutomaticallyFromInline;
    if ( canStartPictureInPictureAutomaticallyFromInline ) [self prepareForPictureInPicture];
}

- (void)prepareForPictureInPicture API_AVAILABLE(ios(14.0)) {
    if ( _pictureInPictureController == nil && self.assetStatus == SJAssetStatusReadyToPlay ) {
        _pictureInPictureController = [SJResourceExternalController.alloc initWithLayer:self.currentPlayerView.layer delegate:self];
        _pictureInPictureController.requiresLinearPlayback = self.requiresLinearPlaybackInPictureInPicture;
        if (@available(iOS 14.2, *)) {
            _pictureInPictureController.canStartPictureInPictureAutomaticallyFromInline = self.canStartPictureInPictureAutomaticallyFromInline;
        }
    }
}

- (void)startPictureInPicture API_AVAILABLE(ios(14.0)) {
    if ( self.currentPlayerView != nil ) {
        [self prepareForPictureInPicture];
        [_pictureInPictureController startPictureInPicture];
    }
}

- (void)stopPictureInPicture API_AVAILABLE(ios(14.0)) {
    [_pictureInPictureController stopPictureInPicture];
}

- (void)cancelPictureInPicture API_AVAILABLE(ios(14.0)) {
    [_pictureInPictureController stopPictureInPicture];
    _pictureInPictureController = nil;
}

- (void)pictureInPictureController:(id<SJPictureInPictureController>)controller statusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0)) {
    if ( [self.delegate respondsToSelector:@selector(playbackController:pictureInPictureStatusDidChange:)] ) {
        [self.delegate playbackController:self pictureInPictureStatusDidChange:status];
    }
}

- (void)pictureInPictureController:(id<SJPictureInPictureController>)controller restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(14.0)) {
    if ( self.restoreUserInterfaceForPictureInPictureStop != nil ) {
        self.restoreUserInterfaceForPictureInPictureStop(self, completionHandler);
    }
    else {
        completionHandler(NO);
    }
}

#pragma mark -

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^_Nullable)(BOOL))completionHandler {
    if ( self.media.trialEndPosition != 0 && CMTimeGetSeconds(time) >= self.media.trialEndPosition ) {
        time = CMTimeMakeWithSeconds(self.media.trialEndPosition * 0.98, NSEC_PER_SEC);
    }
    [self.currentPlayer seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:completionHandler];
}

- (NSTimeInterval)durationWatched {
    NSTimeInterval time = 0;
    for ( AVPlayerItemAccessLogEvent *event in self.currentPlayer.avPlayer.currentItem.accessLog.events) {
        if ( event.durationWatched <= 0 ) continue;
        time += event.durationWatched;
    }
    return time;
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _accurateSeeking = accurateSeeking;
    self.currentPlayer.accurateSeeking = accurateSeeking;
}

- (void)setMinBufferedDuration:(NSTimeInterval)minBufferedDuration {
    [super setMinBufferedDuration:minBufferedDuration];
    self.currentPlayer.minBufferedDuration = minBufferedDuration;
}

- (void)refresh {
    if ( self.media != nil ) [SJExecuteCodeLoader clearPlayerForMedia:self.media];
    if ( @available(iOS 14.0, *) ) {
        self.needsToRefresh_fix339 = NO;
        [self cancelPictureInPicture];
    }
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    [super refresh];
}

- (void)play {
    if (@available(iOS 14.0, *)) {
        self.needsToRefresh_fix339 ? [self refresh] : [super play];
    }
    else {
        [super play];
    }
}

- (void)stop {
    [self cancelGenerateGIFOperation];
    [self cancelExportOperation];
    if ( @available(iOS 14.0, *) ) {
        self.needsToRefresh_fix339 = NO;
        [self cancelPictureInPicture];
    }
    [super stop];
}

- (SJPlaybackType)playbackType {
    return self.currentPlayer.playbackType;
}

#pragma mark -

- (void)_av_playbackTypeDidChange:(NSNotification *)note {
    if ( note.object == self.currentPlayer ) {
        if ( [self.delegate respondsToSelector:@selector(playbackController:playbackTypeDidChange:)] ) {
            [self.delegate playbackController:self playbackTypeDidChange:self.playbackType];
        }
    }
}

- (void)_av_playerViewReadyForDisplay:(NSNotification *)note {
    if ( self.currentPlayerView == note.object ) {
        if ( self.currentPlayerView.isReadyForDisplay ) {
            [self.currentPlayerView setScreenshot:nil];
        }
    }
}

- (void)_av_rateDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.rate != self.currentPlayer.rate ) {
        self.rate = self.currentPlayer.rate;
    }
}

- (void)_av_volumeDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.volume != self.currentPlayer.volume ) {
        self.volume = self.currentPlayer.volume;
    }
}

- (void)_av_mutedDidChange:(NSNotification *)note {
    if ( self.currentPlayer == note.object && self.isMuted != self.currentPlayer.isMuted ) {
        self.muted = self.currentPlayer.isMuted;
    }
}

- (void)_av_assetStatusDidChange:(NSNotification *)note API_AVAILABLE(ios(14.2)) {
    if ( self.currentPlayer == note.object && self.canStartPictureInPictureAutomaticallyFromInline && self.assetStatus == SJAssetStatusReadyToPlay ) {
        [self prepareForPictureInPicture];
    }
}

- (void)_removePlayerForLayerIfNeeded {
    if ( self.pauseWhenAppDidEnterBackground )
        return;
    
    if ( @available(iOS 14.0, *) ) {
        if ( _pictureInPictureController != nil && self.timeControlStatus != SJPlaybackTimeControlStatusPaused ) {
            return;
        }
    }
    
    SJExecuteCodeLayerView *view = self.currentPlayerView;
    view.layer.player = nil;
}
@end


@implementation SJResourcePlaybackController (SJResourcePlaybackAdd)
- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(SJResourcePlaybackController *controller, UIImage * __nullable image, NSError *__nullable error))block {
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_screenshotWithTime:time size:size completionHandler:^(AVAsset * _Nonnull a, UIImage * _Nullable image, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self, image, error);
    }];
}

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                   duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(SJResourcePlaybackController *controller, float progress))progressBlock
                 completion:(void(^)(SJResourcePlaybackController *controller, NSURL * __nullable saveURL, UIImage * __nullable thumbImage))completionBlock
                    failure:(void(^)(SJResourcePlaybackController *controller, NSError * __nullable error))failureBlock {
    [self cancelExportOperation];
    NSURL *exportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"Export.mp4"];
    [[NSFileManager defaultManager] removeItemAtURL:exportURL error:nil];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_exportWithStartTime:beginTime duration:duration toFile:exportURL presetName:presetName progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, AVAsset * _Nullable sandboxAsset, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionBlock ) completionBlock(self, fileURL, thumbImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nullable error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failureBlock ) failureBlock(self, error);
    }];
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                     maximumSize:(CGSize)maximumSize
                        interval:(float)interval
                     gifSavePath:(NSURL *)gifSavePath
                        progress:(void(^)(SJResourcePlaybackController *controller, float progress))progressBlock
                      completion:(void(^)(SJResourcePlaybackController *controller, UIImage *imageGIF, UIImage *screenshot))completion
                         failure:(void(^)(SJResourcePlaybackController *controller, NSError *error))failure {
    [self cancelGenerateGIFOperation];
    __weak typeof(self) _self = self;
    [self.currentPlayer.avPlayer.currentItem.asset sj_generateGIFWithBeginTime:beginTime duration:duration imageMaxSize:maximumSize interval:interval toFile:gifSavePath progress:^(AVAsset * _Nonnull a, float progress) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( progressBlock ) progressBlock(self, progress);
    } success:^(AVAsset * _Nonnull a, UIImage * _Nonnull GIFImage, UIImage * _Nonnull thumbnailImage) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completion ) completion(self, GIFImage, thumbnailImage);
    } failure:^(AVAsset * _Nonnull a, NSError * _Nonnull error) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( failure ) failure(self, error);
    }];
}

- (void)cancelExportOperation {
    [self.currentPlayer.avPlayer.currentItem.asset sj_cancelExportOperation];
}
- (void)cancelGenerateGIFOperation {
    [self.currentPlayer.avPlayer.currentItem.asset sj_cancelGenerateGIFOperation];
}
@end

NS_ASSUME_NONNULL_END
