//
//  SJBaseCommonCode.m
//  SJBaseCommonCodeProject
//
//  Created by admin on 2018/2/2.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJBaseCommonCode.h"
#import <objc/message.h>
#import "SJRotationManager.h"
#import "SJDeviceVolumeAndBrightnessController.h"
#import "SJDeviceVolumeAndBrightnessTargetViewContext.h"
#import "SJCommonCodeRegistrar.h"
#import "SJCommonCodePresentView.h"
#import "SJPlayModelPropertiesObserver.h"
#import "SJTimerControl.h"
#import "UIScrollView+ListViewAutoplaySJAdd.h"
#import "SJResourcePlaybackController.h"
#import "SJReachability.h"
#import "SJControlLayerAppearStateManager.h"
#import "SJFitOnScreenManager.h"
#import "SJFlipTransitionManager.h"
#import "SJBFCodeView.h"
#import "SJSmallViewFloatingController.h"
#import "SJSPDefinitionSwitchingInfo+Private.h"
#import "SJPromptingPopupController.h"
#import "SJTextPopupController.h"
#import "SJBaseCommonCodeConst.h"
#import "SJSubtitlePopupController.h"
#import "SJBaseCommonCode+TestLog.h"
#import "SJCommonCodeResource+SJSubtitlesAdd.h"
#import "SJDanmakuPopupController.h"
#import "SJViewControllerManager.h"
#import "UIView+SJBaseCommonCodeExtended.h"
#import "NSString+SJBaseCommonCodeExtended.h"
#import "SJBFCodeViewInternal.h"

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
typedef struct _SJBFCodeControlInfo {
    struct {
        CGFloat factor;
        NSTimeInterval offsetTime; ///< pan手势触发过程中的偏移量(secs)
    } pan;
    
    struct {
        CGFloat initialRate;
    } longPress;
    
    struct {
        SJBFCodeGestureTypeMask disabledGestures;
        CGFloat rateWhenLongPressGestureTriggered;
        BOOL allowHorizontalTriggeringOfPanGesturesInCells;
    } gestureController;

    struct {
        BOOL automaticallyHides;
        NSTimeInterval delayHidden;
    } placeholder;
    
    struct {
        BOOL isScrollAppeared;
        BOOL pausedWhenScrollDisappeared;
        BOOL hiddenPlayerViewWhenScrollDisappeared;
        BOOL resumePlaybackWhenScrollAppeared;
    } scrollControl;
    
    struct {
        BOOL disableBrightnessSetting;
        BOOL disableVolumeSetting;
    } deviceVolumeAndBrightness;
    
    struct {
        BOOL accurateSeeking;
        BOOL autoplayWhenSetNewAsset;
        BOOL resumePlaybackWhenAppDidEnterForeground;
        BOOL resumePlaybackWhenPlayerHasFinishedSeeking;
        BOOL isUserPaused;
    } playbackControl;
    
    struct {
        BOOL pausedToKeepAppearState;
    } controlLayer;
    
    struct {
        BOOL isEnabled;
    } audioSessionControl;
    
    struct {
        BOOL isAppeared;
        BOOL hiddenFloatSmallViewWhenPlaybackFinished;
    } floatSmallViewControl;
    
} _SJBFCodeControlInfo;

@interface SJBaseCommonCode ()<SJCommonCodePresentViewDelegate, SJBFCodeViewDelegate>
@property (nonatomic) _SJBFCodeControlInfo *controlInfo;

/// - 管理对象: 监听 App在前台, 后台, 耳机插拔, 来电等的通知
@property (nonatomic, strong, readonly) SJCommonCodeRegistrar *registrar;

/// - observe视图的滚动
@property (nonatomic, strong, nullable) SJPlayModelPropertiesObserver *playModelObserver;
@property (nonatomic, strong) SJViewControllerManager *viewControllerManager;
@end

@implementation SJBaseCommonCode {
    SJBFCodeView *_view;
    
    ///
    /// 视频画面的呈现层
    ///
    SJCommonCodePresentView *_presentView;
    
    SJCommonCodeRegistrar *_registrar;
    
    /// 当前资源是否播放过
    /// mpc => Media Playback Controller
    id<SJCommonCodeResourceObserver> _Nullable _mpc_assetObserver;
    
    /// device volume And brightness manager
    id<SJDeviceVolumeAndBrightnessController> _deviceVolumeAndBrightnessController;
    SJDeviceVolumeAndBrightnessTargetViewContext *_deviceVolumeAndBrightnessTargetViewContext;
    id<SJDeviceVolumeAndBrightnessControllerObserver> _deviceVolumeAndBrightnessControllerObserver;

    /// playback controller
    NSError *_Nullable _error;
    id<SJCommonCodePlaybackController> _playbackController;
    SJCommonCodeResource *_resource;
    
    /// control layer appear manager
    id<SJControlLayerAppearManager> _controlLayerAppearManager;
    id<SJControlLayerAppearManagerObserver> _controlLayerAppearManagerObserver;
    
    /// rotation manager
    id<SJRotationManager> _rotationManager;
    id<SJRotationManagerObserver> _rotationManagerObserver;
    
    /// Fit on screen manager
    id<SJFitOnScreenManager> _fitOnScreenManager;
    id<SJFitOnScreenManagerObserver> _fitOnScreenManagerObserver;
    
    /// Flip Transition manager
    id<SJFlipTransitionManager> _flipTransitionManager;
    
    /// Network status
    id<SJReachability> _reachability;
    id<SJReachabilityObserver> _reachabilityObserver;
    
    /// Scroll
    id<SJSmallViewFloatingController> _Nullable _smallViewFloatingController;
    id<SJSmallViewFloatingControllerObserverProtocol> _Nullable _smallViewFloatingControllerObserver;
    
    id<SJSubtitlePopupController> _Nullable _subtitlePopupController;
    id<SJDanmakuPopupController> _Nullable _danmakuPopupController;
    
    AVAudioSessionCategory _mCategory;
    AVAudioSessionCategoryOptions _mCategoryOptions;
    AVAudioSessionSetActiveOptions _mSetActiveOptions;
}

+ (instancetype)shared {
    return [[self alloc] init];
}

+ (NSString *)version {
    return @"v3.7.5";
}

- (void)setSpGravity:(SJSPGravity)spGravity {
    self.playbackController.spGravity = spGravity;
    
    if ( self.watermarkView != nil ) {
        [UIView animateWithDuration:0.28 animations:^{
            [self updateWatermarkViewLayout];
        }];
    }
}
- (SJSPGravity)spGravity {
    return self.playbackController.spGravity;
}

- (nullable __kindof UIViewController *)atViewController {
    return [_presentView lookupResponderForClass:UIViewController.class];
}

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _controlInfo = (_SJBFCodeControlInfo *)calloc(1, sizeof(struct _SJBFCodeControlInfo));
    _controlInfo->placeholder.automaticallyHides = YES;
    _controlInfo->placeholder.delayHidden = 0.8;
    _controlInfo->scrollControl.pausedWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared = YES;
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = YES;
    _controlInfo->playbackControl.autoplayWhenSetNewAsset = YES;
    _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking = YES;
    _controlInfo->floatSmallViewControl.hiddenFloatSmallViewWhenPlaybackFinished = YES;
    _controlInfo->gestureController.rateWhenLongPressGestureTriggered = 2.0;
    _controlInfo->audioSessionControl.isEnabled = YES;
    _controlInfo->pan.factor = 667;
    _mCategory = AVAudioSessionCategoryPlayback;
    _mSetActiveOptions = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
    
    [self _setupViews];
    [self performSelectorOnMainThread:@selector(_prepare) withObject:nil waitUntilDone:NO];
    return self;
}

- (void)_prepare {
    [self fitOnScreenManager];
    if ( !self.onlyFitOnScreen ) [self rotationManager];
    [self controlLayerAppearManager];
    [self deviceVolumeAndBrightnessController];
    [self registrar];
    [self reachability];
    [self gestureController];
    [self _setupViewControllerManager];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    _deviceVolumeAndBrightnessTargetViewContext = [SJDeviceVolumeAndBrightnessTargetViewContext.alloc init];
    _deviceVolumeAndBrightnessTargetViewContext.isFullscreen = _rotationManager.isFullscreen;
    _deviceVolumeAndBrightnessTargetViewContext.isFitOnScreen = _fitOnScreenManager.isFitOnScreen;
    _deviceVolumeAndBrightnessTargetViewContext.isPlayOnScrollView = self.isPlayOnScrollView;
    _deviceVolumeAndBrightnessTargetViewContext.isScrollAppeared = self.isScrollAppeared;
    _deviceVolumeAndBrightnessTargetViewContext.isFloatingMode = _smallViewFloatingController.isAppeared;
    _deviceVolumeAndBrightnessController.targetViewContext = _deviceVolumeAndBrightnessTargetViewContext;
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
#endif
    [NSNotificationCenter.defaultCenter postNotificationName:SJCommonCodePlaybackControllerWillDeallocateNotification object:_playbackController];
    [_presentView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    [_view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
    free(_controlInfo);
}

- (void)playerViewWillMoveToWindow:(SJBFCodeView *)codeView {
    [self.playModelObserver refreshAppearState];
}

///
/// 此处拦截父视图的Tap手势
///
- (nullable UIView *)codeView:(SJBFCodeView *)codeView hitTestForView:(nullable __kindof UIView *)view {

    if ( codeView.hidden || codeView.alpha < 0.01 || !codeView.isUserInteractionEnabled ) return nil;
    
    for ( UIGestureRecognizer *gesture in codeView.superview.gestureRecognizers ) {
        if ( [gesture isKindOfClass:UITapGestureRecognizer.class] && gesture.isEnabled ) {
            gesture.enabled = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                gesture.enabled = YES;
            });
        }
    }
    
    return view;
}

- (void)presentViewDidLayoutSubviews:(SJCommonCodePresentView *)presentView {
    [self updateWatermarkViewLayout];
}

- (void)presentViewDidMoveToWindow:(SJCommonCodePresentView *)presentView {
    if ( _deviceVolumeAndBrightnessController != nil ) [_deviceVolumeAndBrightnessController onTargetViewMoveToWindow];
}

#pragma mark -

- (void)_handleSingleTap:(CGPoint)location {
    if ( self.controlInfo->floatSmallViewControl.isAppeared ) {
        if ( self.smallViewFloatingController.onSingleTapped ) {
            self.smallViewFloatingController.onSingleTapped(self.smallViewFloatingController);
        }
        return;
    }
    
    if ( self.isLockedScreen ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(tappedPlayerOnTheLockedState:)] ) {
            [self.controlLayerDelegate tappedPlayerOnTheLockedState:self];
        }
    }
    else {
        [self.controlLayerAppearManager switchAppearState];
    }
}

- (void)_handleDoubleTap:(CGPoint)location {
    if ( self.controlInfo->floatSmallViewControl.isAppeared ) {
        if ( self.smallViewFloatingController.onDoubleTapped ) {
            self.smallViewFloatingController.onDoubleTapped(self.smallViewFloatingController);
        }
        return;
    }
    
    self.isPaused ? [self play] : [self pauseForUser];
}

- (void)_handlePan:(SJPanGestureTriggeredPosition)position direction:(SJPanGestureMovingDirection)direction state:(SJPanGestureRecognizerState)state translate:(CGPoint)translate {
    switch ( state ) {
        case SJPanGestureRecognizerStateBegan: {
            switch ( direction ) {
                    /// 水平
                case SJPanGestureMovingDirection_H: {
                    if ( self.duration == 0 ) {
                        [_presentView cancelGesture:SJBFCodeGestureType_Pan];
                        return;
                    }
                    
                    self.controlInfo->pan.offsetTime = self.currentTime;
                }
                    break;
                    /// 垂直
                case SJPanGestureMovingDirection_V: { }
                    break;
            }
        }
            break;
        case SJPanGestureRecognizerStateChanged: {
            switch ( direction ) {
                    /// 水平
                case SJPanGestureMovingDirection_H: {
                    NSTimeInterval duration = self.duration;
                    NSTimeInterval previous = self.controlInfo->pan.offsetTime;
                    CGFloat tlt = translate.x;
                    CGFloat add = tlt / self.controlInfo->pan.factor * self.duration;
                    CGFloat offsetTime = previous + add;
                    if ( offsetTime > duration ) offsetTime = duration;
                    else if ( offsetTime < 0 ) offsetTime = 0;
                    self.controlInfo->pan.offsetTime = offsetTime;
                }
                    break;
                    /// 垂直
                case SJPanGestureMovingDirection_V: {
                    CGFloat value = translate.y * 0.005;
                    switch ( position ) {
                            /// brightness
                        case SJPanGestureTriggeredPosition_Left: {
                            float old = self.deviceVolumeAndBrightnessController.brightness;
                            float new = old - value;
                            NSLog(@"brightness.set: old: %lf, new: %lf", old, new);
                            self.deviceVolumeAndBrightnessController.brightness = new;
                        }
                            break;
                            /// volume
                        case SJPanGestureTriggeredPosition_Right: {
                            self.deviceVolumeAndBrightnessController.volume -= value;
                        }
                            break;
                    }
                }
                    break;
            }
        }
            break;
        case SJPanGestureRecognizerStateEnded: {
            switch ( direction ) {
                case SJPanGestureMovingDirection_H: { }
                    break;
                case SJPanGestureMovingDirection_V: { }
                    break;
            }
        }
            break;
    }
    
    if ( direction == SJPanGestureMovingDirection_H ) {
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:panGestureTriggeredInTheHorizontalDirection:progressTime:)] ) {
            [self.controlLayerDelegate commonCode:self panGestureTriggeredInTheHorizontalDirection:state progressTime:self.controlInfo->pan.offsetTime];
        }
    }
}

- (void)_handlePinch:(CGFloat)scale {
    self.spGravity = scale > 1 ?AVLayerVideoGravityResizeAspectFill:AVLayerVideoGravityResizeAspect;
}

- (void)_handleLongPress:(SJLongPressGestureRecognizerState)state {
    switch ( state ) {
        case SJLongPressGestureRecognizerStateBegan:
            self.controlInfo->longPress.initialRate = self.rate;
        case SJLongPressGestureRecognizerStateChanged:
            self.rate = self.rateWhenLongPressGestureTriggered;
            break;
        case SJLongPressGestureRecognizerStateEnded:
            self.rate = self.controlInfo->longPress.initialRate;
            break;
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:longPressGestureStateDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self longPressGestureStateDidChange:state];
    }
}

#pragma mark -

- (void)setControlLayerDataSource:(nullable id<SJCommonCodeControlLayerDataSource>)controlLayerDataSource {
    if ( controlLayerDataSource == _controlLayerDataSource ) return;
    _controlLayerDataSource = controlLayerDataSource;
    
    if ( !controlLayerDataSource ) return;
    
    _controlLayerDataSource.controlView.clipsToBounds = YES;
    
    // install
    UIView *controlView = _controlLayerDataSource.controlView;
    controlView.layer.zPosition = SJBFCodeZIndexes.shared.controlLayerViewZIndex;
    controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    controlView.frame = self.presentView.bounds;
    [self.presentView addSubview:controlView];
    
    if ( [self.controlLayerDataSource respondsToSelector:@selector(installedControlViewToCommonCode:)] ) {
        [self.controlLayerDataSource installedControlViewToCommonCode:self];
    }
}

#pragma mark -

- (void)_setupRotationManager:(id<SJRotationManager>)rotationManager {
    _rotationManager = rotationManager;
    _rotationManagerObserver = nil;
    
    if ( rotationManager == nil || self.onlyFitOnScreen )
        return;
    
    self.viewControllerManager.rotationManager = rotationManager;
    
    rotationManager.superview = self.view;
    rotationManager.target = self.presentView;
    __weak typeof(self) _self = self;
    rotationManager.shouldTriggerRotation = ^BOOL(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        if ( mgr.isFullscreen == NO ) {
            if ( self.playModelObserver.isScrolling ) return NO;
            if ( !self.view.superview ) return NO;
//            UIWindow *_Nullable window = self.view.window;
//            if ( window && !window.isKeyWindow ) return NO;
            if ( self.isPlayOnScrollView && !(self.isScrollAppeared || self.controlInfo->floatSmallViewControl.isAppeared) ) return NO;
            if ( self.touchedOnTheScrollView ) return NO;
        }
        if ( self.isLockedScreen ) return NO;
        
        if ( self.isFitOnScreen )
            return self.allowsRotationInFitOnScreen;
        
        if ( self.viewControllerManager.isViewDisappeared ) return NO;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(canTriggerRotationOfCommonCode:)] ) {
            if ( ![self.controlLayerDelegate canTriggerRotationOfCommonCode:self] )
                return NO;
        }
        if ( self.atViewController.presentedViewController ) return NO;
        if ( self.shouldTriggerRotation && !self.shouldTriggerRotation(self) ) return NO;
        return YES;
    };
    
    _rotationManagerObserver = [rotationManager getObserver];
    _rotationManagerObserver.onRotatingChanged = ^(id<SJRotationManager>  _Nonnull mgr, BOOL isRotating) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        self->_deviceVolumeAndBrightnessTargetViewContext.isFullscreen = mgr.isFullscreen;
        [self->_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
        
        if ( isRotating ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:willRotateView:)] ) {
                [self.controlLayerDelegate commonCode:self willRotateView:mgr.isFullscreen];
            }
            
            [self controlLayerNeedDisappear];
        }
        else {
            [self.playModelObserver refreshAppearState];
            if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:didEndRotation:)] ) {
                [self.controlLayerDelegate commonCode:self didEndRotation:mgr.isFullscreen];
            }
            
            if ( mgr.isFullscreen ) {
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }
            else {
                [UIView animateWithDuration:0.25 animations:^{
                    [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
                }];
            }
        }
    };
    
    _rotationManagerObserver.onTransitioningChanged = ^(id<SJRotationManager>  _Nonnull mgr, BOOL isTransitioning) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:onRotationTransitioningChanged:)] ) {
            [self.controlLayerDelegate commonCode:self onRotationTransitioningChanged:isTransitioning];
        }
    };
}

- (void)_clearRotationManager {
    _viewControllerManager.rotationManager = nil;
    _rotationManagerObserver = nil;
    _rotationManager = nil;
}

#pragma mark -

- (void)_setupFitOnScreenManager:(id<SJFitOnScreenManager>)fitOnScreenManager {
    _fitOnScreenManager = fitOnScreenManager;
    _fitOnScreenManagerObserver = nil;
    
    if ( fitOnScreenManager == nil ) return;
    
    self.viewControllerManager.fitOnScreenManager = fitOnScreenManager;
    
    _fitOnScreenManagerObserver = [fitOnScreenManager getObserver];
    __weak typeof(self) _self = self;
    _fitOnScreenManagerObserver.fitOnScreenWillBeginExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        self->_deviceVolumeAndBrightnessTargetViewContext.isFitOnScreen = mgr.isFitOnScreen;
        [self->_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
        
        if ( self->_rotationManager != nil ) {
            self->_rotationManager.superview = mgr.isFitOnScreen ? self.fitOnScreenManager.superviewInFitOnScreen : self.view;
        }
        if ( self->_smallViewFloatingController != nil ) {
            self->_smallViewFloatingController.targetSuperview = mgr.isFitOnScreen ? self.fitOnScreenManager.superviewInFitOnScreen : self.view;
        }
        
        [self controlLayerNeedDisappear];
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:willFitOnScreen:)] ) {
            [self.controlLayerDelegate commonCode:self willFitOnScreen:mgr.isFitOnScreen];
        }
    };
    
    _fitOnScreenManagerObserver.fitOnScreenDidEndExeBlock = ^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:didCompleteFitOnScreen:)] ) {
            [self.controlLayerDelegate commonCode:self didCompleteFitOnScreen:mgr.isFitOnScreen];
        }
        
        [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
    };
}


#pragma mark -

- (void)_setupControlLayerAppearManager:(id<SJControlLayerAppearManager>)controlLayerAppearManager {
    _controlLayerAppearManager = controlLayerAppearManager;
    _controlLayerAppearManagerObserver = nil;
    
    if ( controlLayerAppearManager == nil ) return;
    
    self.viewControllerManager.controlLayerAppearManager = controlLayerAppearManager;
    
    __weak typeof(self) _self = self;
    _controlLayerAppearManager.canAutomaticallyDisappear = ^BOOL(id<SJControlLayerAppearManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;

        if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerOfCommonCodeCanAutomaticallyDisappear:)] ) {
            if ( ![self.controlLayerDelegate controlLayerOfCommonCodeCanAutomaticallyDisappear:self] ) {
                return NO;
            }
        }
        
        if ( self.canAutomaticallyDisappear && !self.canAutomaticallyDisappear(self) ) {
            return NO;
        }
        return YES;
    };
    
    _controlLayerAppearManagerObserver = [_controlLayerAppearManager getObserver];
    _controlLayerAppearManagerObserver.onAppearChanged = ^(id<SJControlLayerAppearManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        
        if ( mgr.isAppeared ) {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedAppear:)] ) {
                [self.controlLayerDelegate controlLayerNeedAppear:self];
            }
        }
        else {
            if ( [self.controlLayerDelegate respondsToSelector:@selector(controlLayerNeedDisappear:)] ) {
                [self.controlLayerDelegate controlLayerNeedDisappear:self];
            }
        }
        
        if ( !self.isFullscreen || self.isRotating ) {
            [UIView animateWithDuration:0 animations:^{
            } completion:^(BOOL finished) {
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
        else {
            [UIView animateWithDuration:0.25 animations:^{
                [self.viewControllerManager setNeedsStatusBarAppearanceUpdate];
            }];
        }
    };
}


#pragma mark -

- (void)_setupSmallViewFloatingController:(id<SJSmallViewFloatingController>)smallViewFloatingController {
    _smallViewFloatingController = smallViewFloatingController;
    _smallViewFloatingControllerObserver = nil;
    
    if ( smallViewFloatingController == nil ) return;
    
    smallViewFloatingController.targetSuperview = self.view;
    smallViewFloatingController.target = self.presentView;
    
    __weak typeof(self) _self = self;
    _smallViewFloatingControllerObserver = [smallViewFloatingController getObserver];
    _smallViewFloatingControllerObserver.onAppearChanged = ^(id<SJSmallViewFloatingController>  _Nonnull controller) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        BOOL isAppeared = controller.isAppeared;
        self->_deviceVolumeAndBrightnessTargetViewContext.isFloatingMode = isAppeared;
        [self->_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
        self.controlInfo->floatSmallViewControl.isAppeared = isAppeared;
        self.rotationManager.superview = isAppeared ? controller.floatingView : self.view;
    };
}

#pragma mark -

- (SJCommonCodeRegistrar *)registrar {
    if ( _registrar ) return _registrar;
    _registrar = [SJCommonCodeRegistrar new];
    
    __weak typeof(self) _self = self;
    _registrar.willTerminate = ^(SJCommonCodeRegistrar * _Nonnull registrar) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _postNotification:SJCommonCodeApplicationWillTerminateNotification];
    };
    return _registrar;
}

#pragma mark -

- (void)_setupViews {
    _view = [SJBFCodeView new];
    _view.tag = SJBFCodeViewTag;
    _view.delegate = self;
    _view.backgroundColor = [UIColor blackColor];
    
    _presentView = [SJCommonCodePresentView new];
    _presentView.tag = SJPresentViewTag;
    _presentView.frame = _view.bounds;
    _presentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _presentView.placeholderImageView.layer.zPosition = SJBFCodeZIndexes.shared.placeholderImageViewZIndex;
    _presentView.delegate = self;
    [self _configGestureController:_presentView];
    [_view addSubview:_presentView];
    _view.presentView = _presentView;
}

- (void)_setupViewControllerManager {
    if ( _viewControllerManager == nil ) _viewControllerManager = SJViewControllerManager.alloc.init;
    _viewControllerManager.fitOnScreenManager = _fitOnScreenManager;
    _viewControllerManager.rotationManager = _rotationManager;
    _viewControllerManager.controlLayerAppearManager = _controlLayerAppearManager;
    _viewControllerManager.presentView = self.presentView;
    _viewControllerManager.lockedScreen = self.isLockedScreen;
    
    if ( [_rotationManager isKindOfClass:SJRotationManager.class] ) {
        SJRotationManager *mgr = _rotationManager;
        mgr.actionForwarder = _viewControllerManager;
    }
}

- (void)_postNotification:(NSNotificationName)name {
    [self _postNotification:name userInfo:nil];
}

- (void)_postNotification:(NSNotificationName)name userInfo:(nullable NSDictionary *)userInfo {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:self userInfo:userInfo];
}

- (void)_showOrHiddenPlaceholderImageViewIfNeeded {
    if ( _playbackController.isReadyForDisplay ) {
        if ( _controlInfo->placeholder.automaticallyHides ) {
            NSTimeInterval delay = _resource.original != nil ? 0 : _controlInfo->placeholder.delayHidden;
            BOOL animated = _resource.original == nil;
            [self.presentView hidePlaceholderImageViewAnimated:animated delay:delay];
        }
    }
    else {
        [self.presentView setPlaceholderImageViewHidden:NO animated:NO];
    }
}

- (void)_configGestureController:(id<SJGestureController>)gestureController {
    
    __weak typeof(self) _self = self;
    gestureController.gestureRecognizerShouldTrigger = ^BOOL(id<SJGestureController>  _Nonnull control, SJBFCodeGestureType type, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return NO;
        
        if ( self.isRotating )
            return NO;
        
        if ( type != SJBFCodeGestureType_SingleTap && self.isLockedScreen )
            return NO;
        
        if ( SJBFCodeGestureType_Pan == type ) {
            switch ( control.movingDirection ) {
                case SJPanGestureMovingDirection_H: {
                    if ( self.playbackType == SJPlaybackTypeLIVE )
                        return NO;
                    
                    if ( self.duration <= 0 )
                        return NO;
                    
                    if ( self.canSeekToTime != nil && !self.canSeekToTime(self) )
                        return NO;
                    
                    if ( self.isPlayOnScrollView ) {
                        if ( !self.controlInfo->gestureController.allowHorizontalTriggeringOfPanGesturesInCells ) {
                            if ( !self.isFitOnScreen && !self.isRotating )
                                return NO;
                        }
                    }
                }
                    break;
                case SJPanGestureMovingDirection_V: {
                    if ( self.isPlayOnScrollView ) {
                        if ( !self.isFullscreen && !self.isFitOnScreen )
                            return NO;
                    }
                    switch ( control.triggeredPosition ) {
                            /// Brightness
                        case SJPanGestureTriggeredPosition_Left: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting )
                                return NO;
                        }
                            break;
                            /// Volume
                        case SJPanGestureTriggeredPosition_Right: {
                            if ( self.controlInfo->deviceVolumeAndBrightness.disableVolumeSetting || self.isMuted )
                                return NO;
                        }
                            break;
                    }
                }
            }
        }
        
        if ( type == SJBFCodeGestureType_LongPress ) {
            if ( self.assetStatus != SJAssetStatusReadyToPlay || self.isPaused )
                return NO;
        }
        
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:gestureRecognizerShouldTrigger:location:)] ) {
            if ( ![self.controlLayerDelegate commonCode:self gestureRecognizerShouldTrigger:type location:location] )
                return NO;
        }
        
        if ( self.gestureRecognizerShouldTrigger && !self.gestureRecognizerShouldTrigger(self, type, location) ) {
            return NO;
        }
        return YES;
    };
    
    gestureController.singleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleSingleTap:location];
    };
    
    gestureController.doubleTapHandler = ^(id<SJGestureController>  _Nonnull control, CGPoint location) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handleDoubleTap:location];
    };
    
    gestureController.panHandler = ^(id<SJGestureController>  _Nonnull control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePan:position direction:direction state:state translate:translate];
    };
    
    gestureController.pinchHandler = ^(id<SJGestureController>  _Nonnull control, CGFloat scale) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        [self _handlePinch:scale];
    };
    
    gestureController.longPressHandler = ^(id<SJGestureController>  _Nonnull control, SJLongPressGestureRecognizerState state) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _handleLongPress:state];
    };
}

- (void)_updateCurrentPlayingIndexPathIfNeeded:(SJPlayModel *)playModel {
    if ( !playModel )
        return;
    
    // 维护当前播放的indexPath
    UIScrollView *scrollView = playModel.inScrollView;
    if ( scrollView.sj_enabledAutoplay ) {
        scrollView.sj_currentPlayingIndexPath = playModel.indexPath;
    }
}

/// - 当用户触摸到TableView或者ScrollView时, 这个值为YES.
/// - 这个值用于旋转的条件之一, 如果用户触摸在TableView或者ScrollView上时, 将不会自动旋转.
- (BOOL)touchedOnTheScrollView {
    return _playModelObserver.isTouched;
}
@end

@implementation SJBaseCommonCode (AudioSession)
- (void)setAudioSessionControlEnabled:(BOOL)audioSessionControlEnabled {
    _controlInfo->audioSessionControl.isEnabled = audioSessionControlEnabled;
}

- (BOOL)isAudioSessionControlEnabled {
    return _controlInfo->audioSessionControl.isEnabled;
}

- (void)setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options {
    _mCategory = category;
    _mCategoryOptions = options;
    
    NSError *error = nil;
    if ( ![AVAudioSession.sharedInstance setCategory:_mCategory withOptions:_mCategoryOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
}

- (void)setActiveOptions:(AVAudioSessionSetActiveOptions)options {
    _mSetActiveOptions = options;
    NSError *error = nil;
    if ( ![AVAudioSession.sharedInstance setActive:YES withOptions:_mSetActiveOptions error:&error] ) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }
}
@end

@implementation SJBaseCommonCode (Placeholder)
- (UIView<SJCommonCodePresentView> *)presentView {
    return _presentView;
}

- (void)setAutomaticallyHidesPlaceholderImageView:(BOOL)isHidden {
    _controlInfo->placeholder.automaticallyHides = isHidden;
}
- (BOOL)automaticallyHidesPlaceholderImageView {
    return _controlInfo->placeholder.automaticallyHides;
}


- (void)setDelayInSecondsForHiddenPlaceholderImageView:(NSTimeInterval)delayHidden {
    _controlInfo->placeholder.delayHidden = delayHidden;
}
- (NSTimeInterval)delayInSecondsForHiddenPlaceholderImageView {
    return _controlInfo->placeholder.delayHidden;
}
@end


#pragma mark -

@implementation SJBaseCommonCode (VideoFlipTransition)
- (void)setFlipTransitionManager:(id<SJFlipTransitionManager> _Nullable)flipTransitionManager {
    _flipTransitionManager = flipTransitionManager;
}
- (id<SJFlipTransitionManager>)flipTransitionManager {
    if ( _flipTransitionManager )
        return _flipTransitionManager;
    
    _flipTransitionManager = [[SJFlipTransitionManager alloc] initWithTarget:self.playbackController.codeView];
    return _flipTransitionManager;
}

- (id<SJFlipTransitionManagerObserver>)flipTransitionObserver {
    id<SJFlipTransitionManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.flipTransitionManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark - 控制
@implementation SJBaseCommonCode (Playback)
- (void)setPlaybackController:(nullable __kindof id<SJCommonCodePlaybackController>)playbackController {
    if ( _playbackController != nil ) {
        [_playbackController.codeView removeFromSuperview];
        [NSNotificationCenter.defaultCenter postNotificationName:SJCommonCodePlaybackControllerWillDeallocateNotification object:_playbackController];
    }
    _playbackController = playbackController;
    [self _playbackControllerDidChange];
}

- (__kindof id<SJCommonCodePlaybackController>)playbackController {
    if ( _playbackController ) return _playbackController;
    _playbackController = [SJResourcePlaybackController new];
    [self _playbackControllerDidChange];
    return _playbackController;
}

- (void)_playbackControllerDidChange {
    if ( !_playbackController )
        return;
    
    _playbackController.delegate = self;
    
    if ( _playbackController.codeView.superview != self.presentView ) {
        _playbackController.codeView.frame = self.presentView.bounds;
        _playbackController.codeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _playbackController.codeView.layer.zPosition = SJBFCodeZIndexes.shared.playbackViewZIndex;
        [_presentView addSubview:_playbackController.codeView];
    }
    
    _flipTransitionManager.target = _playbackController.codeView;
}

- (SJPlaybackObservation *)playbackObserver {
    SJPlaybackObservation *obs = objc_getAssociatedObject(self, _cmd);
    if ( obs == nil ) {
        obs = [[SJPlaybackObservation alloc] initWithPlayer:self];
        objc_setAssociatedObject(self, _cmd, obs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obs;
}

- (void)switchVideoDefinition:(SJCommonCodeResource *)resource {
    self.definitionSwitchingInfo.switchingAsset = resource;
    [self.playbackController switchVideoDefinition:resource];
}

- (SJSPDefinitionSwitchingInfo *)definitionSwitchingInfo {
    SJSPDefinitionSwitchingInfo *_Nullable definitionSwitchingInfo = objc_getAssociatedObject(self, _cmd);
    if ( definitionSwitchingInfo == nil ) {
        definitionSwitchingInfo = [SJSPDefinitionSwitchingInfo new];
        objc_setAssociatedObject(self, @selector(definitionSwitchingInfo), definitionSwitchingInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return definitionSwitchingInfo;
}

- (void)_resetDefinitionSwitchingInfo {
    SJSPDefinitionSwitchingInfo *info = self.definitionSwitchingInfo;
    info.currentPlayingAsset = nil;
    info.switchingAsset = nil;
    info.status = SJDefinitionSwitchStatusUnknown;
}

- (SJPlaybackType)playbackType {
    return _playbackController.playbackType;
}

#pragma mark -

- (NSError *_Nullable)error {
    return _playbackController.error;
}

- (SJAssetStatus)assetStatus {
    return _playbackController.assetStatus;
}

- (SJPlaybackTimeControlStatus)timeControlStatus {
    return _playbackController.timeControlStatus;
}

- (BOOL)isPaused { return self.timeControlStatus == SJPlaybackTimeControlStatusPaused; }
- (BOOL)isPlaying { return self.timeControlStatus == SJPlaybackTimeControlStatusPlaying; }
- (BOOL)isBuffering { return self.timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay && self.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason; }
- (BOOL)isEvaluating { return self.timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay && self.reasonForWaitingToPlay == SJWaitingWhileEvaluatingBufferingRateReason; }
- (BOOL)isNoAssetToPlay { return self.timeControlStatus == SJPlaybackTimeControlStatusWaitingToPlay && self.reasonForWaitingToPlay == SJWaitingWithNoAssetToPlayReason; }

- (BOOL)isPlaybackFailed {
    return self.assetStatus == SJAssetStatusFailed;
}

- (nullable SJWaitingReason)reasonForWaitingToPlay {
    return _playbackController.reasonForWaitingToPlay;
}

- (BOOL)isPlaybackFinished {
    return _playbackController.isPlaybackFinished;
}

- (nullable SJFinishedReason)finishedReason {
    return _playbackController.finishedReason;
}

- (BOOL)isPlayed {
    return _playbackController.isPlayed;
}

- (BOOL)isReplayed {
    return _playbackController.isReplayed;
}

- (BOOL)isUserPaused {
    return _controlInfo->playbackControl.isUserPaused;
}

- (NSTimeInterval)currentTime {
    return self.playbackController.currentTime;
}

- (NSTimeInterval)duration {
    return self.playbackController.duration;
}

- (NSTimeInterval)playableDuration {
    return self.playbackController.playableDuration;
}

- (NSTimeInterval)durationWatched {
    return self.playbackController.durationWatched;
}

- (NSString *)stringForSeconds:(NSInteger)secs {
    return [NSString stringWithCurrentTime:secs duration:self.duration];
}

#pragma mark -
// 1.
- (void)setResource:(nullable SJCommonCodeResource *)resource {
    
    [self _resetDefinitionSwitchingInfo];

    [self _postNotification:SJCommonCodeResourceWillChangeNotification];
    
    _resource = resource;
    
    [self _postNotification:SJCommonCodeResourceDidChangeNotification];
      
    //
    // prepareToPlay
    //
    self.playbackController.media = resource;
    self.definitionSwitchingInfo.currentPlayingAsset = resource;
    [self _updateAssetObservers];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:prepareToPlay:)] ) {
        [self.controlLayerDelegate commonCode:self prepareToPlay:resource];
    }
    
    if ( resource == nil ) {
        [self stop];
        return;
    }

    if ( resource.subtitles != nil || _subtitlePopupController != nil ) {
        self.subtitlePopupController.subtitles = resource.subtitles;
    }
    
    [(SJMTPlaybackController *)self.playbackController prepareToPlay];
    [self _tryToPlayIfNeeded];
}
- (nullable SJCommonCodeResource *)resource {
    return _resource;
}

- (void)_tryToPlayIfNeeded {
    if ( self.registrar.state == SJCommonCodeAppState_Background && self.isPausedInBackground )
        return;
    if ( _controlInfo->playbackControl.autoplayWhenSetNewAsset == NO )
        return;
    if ( self.isPlayOnScrollView && self.isScrollAppeared == NO && self.pausedWhenScrollDisappeared )
        return;
    
    [self play];
}

- (void)_updateAssetObservers {
    [self _updateCurrentPlayingIndexPathIfNeeded:_resource.playModel];
    [self _updatePlayModelObserver:_resource.playModel];
    _mpc_assetObserver = [_resource getObserver];
    __weak typeof(self) _self = self;
    _mpc_assetObserver.playModelDidChangeExeBlock = ^(SJCommonCodeResource * _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        [self _updateCurrentPlayingIndexPathIfNeeded:asset.playModel];
        [self _updatePlayModelObserver:asset.playModel];
    };
    
    _deviceVolumeAndBrightnessTargetViewContext.isPlayOnScrollView = self.isPlayOnScrollView;
    _deviceVolumeAndBrightnessTargetViewContext.isScrollAppeared = self.isScrollAppeared;
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
}

- (void)refresh {
    if ( !self.resource ) return;
    [self _postNotification:SJCommonCodePlaybackWillRefreshNotification];
    [_playbackController refresh];
    [self play];
    [self _postNotification:SJCommonCodePlaybackDidRefreshNotification];
}

- (void)setPlayerVolume:(float)playerVolume {
    self.playbackController.volume = playerVolume;
}

- (float)playerVolume {
    return self.playbackController.volume;
}

- (void)setMuted:(BOOL)muted {
    self.playbackController.muted = muted;
}

- (BOOL)isMuted {
    return self.playbackController.muted;
}

- (void)setAutoplayWhenSetNewAsset:(BOOL)autoplayWhenSetNewAsset {
    _controlInfo->playbackControl.autoplayWhenSetNewAsset = autoplayWhenSetNewAsset;
}
- (BOOL)autoplayWhenSetNewAsset {
    return _controlInfo->playbackControl.autoplayWhenSetNewAsset;
}

- (void)setPausedInBackground:(BOOL)pausedInBackground {
    self.playbackController.pauseWhenAppDidEnterBackground = pausedInBackground;
}
- (BOOL)isPausedInBackground {
    return self.playbackController.pauseWhenAppDidEnterBackground;
}

- (void)setResumePlaybackWhenAppDidEnterForeground:(BOOL)resumePlaybackWhenAppDidEnterForeground {
    _controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground = resumePlaybackWhenAppDidEnterForeground;
}
- (BOOL)resumePlaybackWhenAppDidEnterForeground {
    return _controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground;
}

- (void)setCanPlayAnAsset:(nullable BOOL (^)(__kindof SJBaseCommonCode * _Nonnull))canPlayAnAsset {
    objc_setAssociatedObject(self, @selector(canPlayAnAsset), canPlayAnAsset, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (nullable BOOL (^)(__kindof SJBaseCommonCode * _Nonnull))canPlayAnAsset {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setResumePlaybackWhenPlayerHasFinishedSeeking:(BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking = resumePlaybackWhenPlayerHasFinishedSeeking;
}
- (BOOL)resumePlaybackWhenPlayerHasFinishedSeeking {
    return _controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking;
}

- (void)play {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPlayForCommonCode:)] ) {
        if ( ![self.controlLayerDelegate canPerformPlayForCommonCode:self] )
            return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) )
        return;
    
    if ( self.registrar.state == SJCommonCodeAppState_Background && self.isPausedInBackground ) return;

    _controlInfo->playbackControl.isUserPaused = NO;
    
    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self refresh];
        return;
    }
    
    if (_controlInfo->audioSessionControl.isEnabled) {
        NSError *error = nil;
        if ( ![AVAudioSession.sharedInstance setCategory:_mCategory withOptions:_mCategoryOptions error:&error] ) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
        if ( ![AVAudioSession.sharedInstance setActive:YES withOptions:_mSetActiveOptions error:&error] ) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }
    }

    [_playbackController play];

    [self.controlLayerAppearManager resume];
}

- (void)pause {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformPauseForCommonCode:)] ) {
        if ( ![self.controlLayerDelegate canPerformPauseForCommonCode:self] )
            return;
    }
    
    [_playbackController pause];
}

- (void)pauseForUser {
    _controlInfo->playbackControl.isUserPaused = YES;
    [self pause];
}

- (void)stop {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(canPerformStopForCommonCode:)] ) {
        if ( ![self.controlLayerDelegate canPerformStopForCommonCode:self] )
            return;
    }
    
    [self _postNotification:SJCommonCodePlaybackWillStopNotification];

    _controlInfo->playbackControl.isUserPaused = NO;
    _subtitlePopupController.subtitles = nil;
    _playModelObserver = nil;
    _resource = nil;
    [_playbackController stop];
    [self _resetDefinitionSwitchingInfo];
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
    
    [self _postNotification:SJCommonCodePlaybackDidStopNotification];
}

- (void)replay {
    if ( !self.resource ) return;
    if ( self.assetStatus == SJAssetStatusFailed ) {
        [self refresh];
        return;
    }

    _controlInfo->playbackControl.isUserPaused = NO;
    [_playbackController replay];
}

- (void)setCanSeekToTime:(BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))canSeekToTime {
    objc_setAssociatedObject(self, @selector(canSeekToTime), canSeekToTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))canSeekToTime {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAccurateSeeking:(BOOL)accurateSeeking {
    _controlInfo->playbackControl.accurateSeeking = accurateSeeking;
}
- (BOOL)accurateSeeking {
    return _controlInfo->playbackControl.accurateSeeking;
}

- (void)seekToTime:(NSTimeInterval)secs completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    if ( isnan(secs) ) {
        return;
    }
    
    if ( secs > self.playbackController.duration ) {
        secs = self.playbackController.duration * 0.98;
    }
    else if ( secs < 0 ) {
        secs = 0;
    }
    
    [self seekToTime:CMTimeMakeWithSeconds(secs, NSEC_PER_SEC)
     toleranceBefore:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
      toleranceAfter:self.accurateSeeking ? kCMTimeZero : kCMTimePositiveInfinity
   completionHandler:completionHandler];
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter completionHandler:(void (^ _Nullable)(BOOL))completionHandler {
    if ( self.canSeekToTime && !self.canSeekToTime(self) ) {
        return;
    }
    
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( self.assetStatus != SJAssetStatusReadyToPlay ) {
        if ( completionHandler ) completionHandler(NO);
        return;
    }
    
    __weak typeof(self) _self = self;
    [self.playbackController seekToTime:time toleranceBefore:toleranceBefore toleranceAfter:toleranceAfter completionHandler:^(BOOL finished) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( finished && self.controlInfo->playbackControl.resumePlaybackWhenPlayerHasFinishedSeeking ) {
            [self play];
        }
        if ( completionHandler ) completionHandler(finished);
    }];
}

- (void)setRate:(float)rate {
    if ( self.canPlayAnAsset && !self.canPlayAnAsset(self) ) {
        return;
    }
    
    if ( _playbackController.rate == rate )
        return;
    
    self.playbackController.rate = rate;
}

- (float)rate {
    return self.playbackController.rate;
}

- (void)_updatePlayModelObserver:(SJPlayModel *)playModel {
    // clean
    _playModelObserver = nil;
    _controlInfo->scrollControl.isScrollAppeared = NO;
    
    if ( playModel == nil || [playModel isMemberOfClass:SJPlayModel.class] )
        return;
    
    // update playModel
    self.playModelObserver = [[SJPlayModelPropertiesObserver alloc] initWithPlayModel:playModel];
    self.playModelObserver.delegate = (id)self;
    [self.playModelObserver refreshAppearState];
}

#pragma mark - SJCommonCodePlaybackControllerDelegate

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller assetStatusDidChange:(SJAssetStatus)status {
 
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCodePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate commonCodePlaybackStatusDidChange:self];
    }
    
    [self _postNotification:SJCommonCodeAssetStatusDidChangeNotification];
    
#ifdef SJDEBUG
    [self showLog_AssetStatus];
#endif
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller timeControlStatusDidChange:(SJPlaybackTimeControlStatus)status {
    
    BOOL isBuffering = self.isBuffering || self.assetStatus == SJAssetStatusPreparing;
    isBuffering && !self.resource.mtSource.isFileURL ? [self.reachability startRefresh] : [self.reachability stopRefresh];
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCodePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate commonCodePlaybackStatusDidChange:self];
    }

    [self _postNotification:SJCommonCodePlaybackTimeControlStatusDidChangeNotification];
        
    if ( status == SJPlaybackTimeControlStatusPaused && self.pausedToKeepAppearState ) {
        [self.controlLayerAppearManager keepAppearState];
    }
    
#ifdef SJDEBUG
    [self showLog_TimeControlStatus];
#endif
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller volumeDidChange:(float)volume {
    [self _postNotification:SJCommonCodeVolumeDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller rateDidChange:(float)rate {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:rateChanged:)] ) {
        [self.controlLayerDelegate commonCode:self rateChanged:rate];
    }
    
    [self _postNotification:SJCommonCodeRateDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller mutedDidChange:(BOOL)isMuted {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:muteChanged:)] ) {
        [self.controlLayerDelegate commonCode:self muteChanged:isMuted];
    }
    [self _postNotification:SJCommonCodeMutedDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller pictureInPictureStatusDidChange:(SJPictureInPictureStatus)status API_AVAILABLE(ios(14.0)) {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:pictureInPictureStatusDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self pictureInPictureStatusDidChange:status];
    }
    
    _deviceVolumeAndBrightnessTargetViewContext.isPictureInPictureMode = (status == SJPictureInPictureStatusRunning);
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
    
    [self _postNotification:SJCommonCodePictureInPictureStatusDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller durationDidChange:(NSTimeInterval)duration {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:durationDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self durationDidChange:duration];
    }
    
    [self _postNotification:SJCommonCodeDurationDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller currentTimeDidChange:(NSTimeInterval)currentTime {
    _subtitlePopupController.currentTime = currentTime;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:currentTimeDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self currentTimeDidChange:currentTime];
    }
    
    [self _postNotification:SJCommonCodeCurrentTimeDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playbackDidFinish:(SJFinishedReason)reason {
    if ( _smallViewFloatingController.isAppeared && self.hiddenFloatSmallViewWhenPlaybackFinished ) {
        [_smallViewFloatingController dismiss];
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCodePlaybackStatusDidChange:)] ) {
        [self.controlLayerDelegate commonCodePlaybackStatusDidChange:self];
    }
    
    [self _postNotification:SJCommonCodePlaybackDidFinishNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller presentationSizeDidChange:(CGSize)presentationSize {
    [self updateWatermarkViewLayout];
    
    if ( self.presentationSizeDidChangeExeBlock )
        self.presentationSizeDidChangeExeBlock(self);
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:presentationSizeDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self presentationSizeDidChange:presentationSize];
    }
    
    [self _postNotification:SJCommonCodePresentationSizeDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playbackTypeDidChange:(SJPlaybackType)playbackType {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:playbackTypeDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self playbackTypeDidChange:playbackType];
    }
    
    [self _postNotification:SJCommonCodePlaybackTypeDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller playableDurationDidChange:(NSTimeInterval)playableDuration {
    if ( controller.duration == 0 ) return;

    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:playableDurationDidChange:)] ) {
        [self.controlLayerDelegate commonCode:self playableDurationDidChange:playableDuration];
    }
    
    [self _postNotification:SJCommonCodePlayableDurationDidChangeNotification];
}

- (void)playbackControllerIsReadyForDisplay:(id<SJCommonCodePlaybackController>)controller {
    [self _showOrHiddenPlaceholderImageViewIfNeeded];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller willSeekToTime:(CMTime)time {
    [self _postNotification:SJCommonCodePlaybackWillSeekNotification userInfo:@{
        SJCommonCodeNotificationUserInfoKeySeekTime : [NSValue valueWithCMTime:time]
    }];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller didSeekToTime:(CMTime)time {
    [self _postNotification:SJCommonCodePlaybackDidSeekNotification userInfo:@{
        SJCommonCodeNotificationUserInfoKeySeekTime : [NSValue valueWithCMTime:time]
    }];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller switchingDefinitionStatusDidChange:(SJDefinitionSwitchStatus)status media:(id<SJMTModelProtocol>)media {
    
    if ( status == SJDefinitionSwitchStatusFinished ) {
        _resource = (id)media;
        self.definitionSwitchingInfo.currentPlayingAsset = _resource;
        [self _updateAssetObservers];
    }
    
    self.definitionSwitchingInfo.status = status;
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:switchingDefinitionStatusDidChange:media:)] ) {
        [self.controlLayerDelegate commonCode:self switchingDefinitionStatusDidChange:status media:media];
    }
    
    [self _postNotification:SJCommonCodeDefinitionSwitchStatusDidChangeNotification];
}

- (void)playbackController:(id<SJCommonCodePlaybackController>)controller didReplay:(id<SJMTModelProtocol>)media {
    [self _postNotification:SJCommonCodePlaybackDidReplayNotification];
}

- (void)applicationDidBecomeActiveWithPlaybackController:(id<SJCommonCodePlaybackController>)controller {
    BOOL canPlay = self.resource != nil &&
                   self.isPaused &&
                   self.controlInfo->playbackControl.resumePlaybackWhenAppDidEnterForeground &&
                  !self.vc_isDisappeared;
    if ( self.isPlayOnScrollView ) {
        if ( canPlay && self.isScrollAppeared ) [self play];
    }
    else {
        if ( canPlay ) [self play];
    }

    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidBecomeActiveWithCommonCode:)] ) {
        [self.controlLayerDelegate applicationDidBecomeActiveWithCommonCode:self];
    }
}

- (void)applicationWillResignActiveWithPlaybackController:(id<SJCommonCodePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationWillResignActiveWithCommonCode:)] ) {
        [self.controlLayerDelegate applicationWillResignActiveWithCommonCode:self];
    }
}

- (void)applicationWillEnterForegroundWithPlaybackController:(id<SJCommonCodePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidEnterBackgroundWithCommonCode:)] ) {
        [self.controlLayerDelegate applicationDidEnterBackgroundWithCommonCode:self];
    }
    [self _postNotification:SJCommonCodeApplicationWillEnterForegroundNotification];
}

- (void)applicationDidEnterBackgroundWithPlaybackController:(id<SJCommonCodePlaybackController>)controller {
    if ( [self.controlLayerDelegate respondsToSelector:@selector(applicationDidEnterBackgroundWithCommonCode:)] ) {
        [self.controlLayerDelegate applicationDidEnterBackgroundWithCommonCode:self];
    }
    [self _postNotification:SJCommonCodeApplicationDidEnterBackgroundNotification];
}

@end


#pragma mark - Network

@implementation SJBaseCommonCode (Network)

- (void)setReachability:(id<SJReachability> _Nullable)reachability {
    _reachability = reachability;
    [self _needUpdateReachabilityProperties];
}

- (id<SJReachability>)reachability {
    if ( _reachability )
        return _reachability;
    _reachability = [SJReachability shared];
    [self _needUpdateReachabilityProperties];
    return _reachability;
}

- (void)_needUpdateReachabilityProperties {
    if ( _reachability == nil ) return;
    
    _reachabilityObserver = [_reachability getObserver];
    __weak typeof(self) _self = self;
    _reachabilityObserver.networkStatusDidChangeExeBlock = ^(id<SJReachability> r) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:reachabilityChanged:)] ) {
            [self.controlLayerDelegate commonCode:self reachabilityChanged:r.networkStatus];
        }
    };
}

- (id<SJReachabilityObserver>)reachabilityObserver {
    id<SJReachabilityObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.reachability getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}
@end

#pragma mark -

@implementation SJBaseCommonCode (DeviceVolumeAndBrightness)

- (void)setDeviceVolumeAndBrightnessController:(id<SJDeviceVolumeAndBrightnessController> _Nullable)deviceVolumeAndBrightnessController {
    _deviceVolumeAndBrightnessController = deviceVolumeAndBrightnessController;
    [self _configDeviceVolumeAndBrightnessController:self.deviceVolumeAndBrightnessController];
}

- (id<SJDeviceVolumeAndBrightnessController>)deviceVolumeAndBrightnessController {
    if ( _deviceVolumeAndBrightnessController )
        return _deviceVolumeAndBrightnessController;
    _deviceVolumeAndBrightnessController = [SJDeviceVolumeAndBrightnessController.alloc init];
    [self _configDeviceVolumeAndBrightnessController:_deviceVolumeAndBrightnessController];
    return _deviceVolumeAndBrightnessController;
}

- (void)_configDeviceVolumeAndBrightnessController:(id<SJDeviceVolumeAndBrightnessController>)mgr {
    mgr.targetViewContext = _deviceVolumeAndBrightnessTargetViewContext;
    mgr.target = self.presentView;
    _deviceVolumeAndBrightnessControllerObserver = [mgr getObserver];
    __weak typeof(self) _self = self;
    _deviceVolumeAndBrightnessControllerObserver.volumeDidChangeExeBlock = ^(id<SJDeviceVolumeAndBrightnessController>  _Nonnull mgr, float volume) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:volumeChanged:)] ) {
            [self.controlLayerDelegate commonCode:self volumeChanged:volume];
        }
    };
    
    _deviceVolumeAndBrightnessControllerObserver.brightnessDidChangeExeBlock = ^(id<SJDeviceVolumeAndBrightnessController>  _Nonnull mgr, float brightness) {
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCode:brightnessChanged:)] ) {
            [self.controlLayerDelegate commonCode:self brightnessChanged:brightness];
        }
    };
    
    [mgr onTargetViewMoveToWindow];
    [mgr onTargetViewContextUpdated];
}

- (id<SJDeviceVolumeAndBrightnessControllerObserver>)deviceVolumeAndBrightnessObserver {
    id<SJDeviceVolumeAndBrightnessControllerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.deviceVolumeAndBrightnessController getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setDisableBrightnessSetting:(BOOL)disableBrightnessSetting {
    _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting = disableBrightnessSetting;
}
- (BOOL)disableBrightnessSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableBrightnessSetting;
}

- (void)setDisableVolumeSetting:(BOOL)disableVolumeSetting {
    _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting = disableVolumeSetting;
}
- (BOOL)disableVolumeSetting {
    return _controlInfo->deviceVolumeAndBrightness.disableVolumeSetting;
}

@end



#pragma mark -

@implementation SJBaseCommonCode (Life)
/// You should call it when view did appear
- (void)vc_viewDidAppear {
    [self.viewControllerManager viewDidAppear];
    [self.playModelObserver refreshAppearState];
}
/// You should call it when view will disappear
- (void)vc_viewWillDisappear {
    [self.viewControllerManager viewWillDisappear];
}
- (void)vc_viewDidDisappear {
    [self.viewControllerManager viewDidDisappear];
    [self pause];
}
- (BOOL)vc_prefersStatusBarHidden {
    return self.viewControllerManager.prefersStatusBarHidden;
}
- (UIStatusBarStyle)vc_preferredStatusBarStyle {
    return self.viewControllerManager.preferredStatusBarStyle;
}

- (void)setVc_isDisappeared:(BOOL)vc_isDisappeared {
    vc_isDisappeared ?  [self.viewControllerManager viewWillDisappear] :
                        [self.viewControllerManager viewDidAppear];
}
- (BOOL)vc_isDisappeared {
    return self.viewControllerManager.isViewDisappeared;
}

- (void)needShowStatusBar {
    [self.viewControllerManager showStatusBar];
}

- (void)needHiddenStatusBar {
    [self.viewControllerManager hiddenStatusBar];
}
@end

#pragma mark - Gesture

@implementation SJBaseCommonCode (Gesture)

- (id<SJGestureController>)gestureController {
    return _presentView;
}

- (void)setGestureRecognizerShouldTrigger:(BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull, SJBFCodeGestureType, CGPoint))gestureRecognizerShouldTrigger {
    objc_setAssociatedObject(self, @selector(gestureRecognizerShouldTrigger), gestureRecognizerShouldTrigger, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull, SJBFCodeGestureType, CGPoint))gestureRecognizerShouldTrigger {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAllowHorizontalTriggeringOfPanGesturesInCells:(BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    _controlInfo->gestureController.allowHorizontalTriggeringOfPanGesturesInCells = allowHorizontalTriggeringOfPanGesturesInCells;
}

- (BOOL)allowHorizontalTriggeringOfPanGesturesInCells {
    return _controlInfo->gestureController.allowHorizontalTriggeringOfPanGesturesInCells;
}

- (void)setRateWhenLongPressGestureTriggered:(CGFloat)rateWhenLongPressGestureTriggered {
    _controlInfo->gestureController.rateWhenLongPressGestureTriggered = rateWhenLongPressGestureTriggered;
}
- (CGFloat)rateWhenLongPressGestureTriggered {
    return _controlInfo->gestureController.rateWhenLongPressGestureTriggered;
}

- (void)setOffsetFactorForHorizontalPanGesture:(CGFloat)offsetFactorForHorizontalPanGesture {
    NSAssert(offsetFactorForHorizontalPanGesture != 0, @"The factor can't be set to 0!");
    _controlInfo->pan.factor = offsetFactorForHorizontalPanGesture;
}
- (CGFloat)offsetFactorForHorizontalPanGesture {
    return _controlInfo->pan.factor;
}
@end


#pragma mark - 控制层

@implementation SJBaseCommonCode (ControlLayer)
/// 控制层需要显示
- (void)controlLayerNeedAppear {
    [self.controlLayerAppearManager needAppear];
}

/// 控制层需要隐藏
- (void)controlLayerNeedDisappear {
    [self.controlLayerAppearManager needDisappear];
}

- (void)setControlLayerAppearManager:(id<SJControlLayerAppearManager> _Nullable)controlLayerAppearManager {
    [self _setupControlLayerAppearManager:controlLayerAppearManager];
}

- (id<SJControlLayerAppearManager>)controlLayerAppearManager {
    if ( _controlLayerAppearManager == nil ) {
        [self _setupControlLayerAppearManager:SJControlLayerAppearStateManager.alloc.init];
    }
    return _controlLayerAppearManager;
}

- (id<SJControlLayerAppearManagerObserver>)controlLayerAppearObserver {
    id<SJControlLayerAppearManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.controlLayerAppearManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setCanAutomaticallyDisappear:(BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))canAutomaticallyDisappear {
    objc_setAssociatedObject(self, @selector(canAutomaticallyDisappear), canAutomaticallyDisappear, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))canAutomaticallyDisappear {
    return objc_getAssociatedObject(self, _cmd);
}

/// 控制层是否显示
- (void)setControlLayerAppeared:(BOOL)controlLayerAppeared {
    controlLayerAppeared ? [self.controlLayerAppearManager needAppear] :
                           [self.controlLayerAppearManager needDisappear];
}
- (BOOL)isControlLayerAppeared {
    return self.controlLayerAppearManager.isAppeared;
}

/// 暂停时是否保持控制层一直显示
- (void)setPausedToKeepAppearState:(BOOL)pausedToKeepAppearState {
    _controlInfo->controlLayer.pausedToKeepAppearState = pausedToKeepAppearState;
}
- (BOOL)pausedToKeepAppearState {
    return _controlInfo->controlLayer.pausedToKeepAppearState;
}
@end



#pragma mark - 充满屏幕

@implementation SJBaseCommonCode (FitOnScreen)

- (void)setFitOnScreenManager:(id<SJFitOnScreenManager> _Nullable)fitOnScreenManager {
    [self _setupFitOnScreenManager:fitOnScreenManager];
}

- (id<SJFitOnScreenManager>)fitOnScreenManager {
    if ( _fitOnScreenManager == nil ) {
        [self _setupFitOnScreenManager:[[SJFitOnScreenManager alloc] initWithTarget:self.presentView targetSuperview:self.view]];
    }
    return _fitOnScreenManager;
}

- (id<SJFitOnScreenManagerObserver>)fitOnScreenObserver {
    id<SJFitOnScreenManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.fitOnScreenManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setOnlyFitOnScreen:(BOOL)onlyFitOnScreen {
    objc_setAssociatedObject(self, @selector(onlyFitOnScreen), @(onlyFitOnScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( onlyFitOnScreen ) {
        [self _clearRotationManager];
    }
    else {
        [self rotationManager];
    }
}

- (BOOL)onlyFitOnScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isFitOnScreen {
    return self.fitOnScreenManager.isFitOnScreen;
}
- (void)setFitOnScreen:(BOOL)fitOnScreen {
    [self setFitOnScreen:fitOnScreen animated:YES];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated {
    [self setFitOnScreen:fitOnScreen animated:animated completionHandler:nil];
}
- (void)setFitOnScreen:(BOOL)fitOnScreen animated:(BOOL)animated completionHandler:(nullable void(^)(__kindof SJBaseCommonCode *player))completionHandler {
    NSAssert(!self.isFullscreen, @"横屏全屏状态下, 无法执行竖屏全屏!");
    
    __weak typeof(self) _self = self;
    [self.fitOnScreenManager setFitOnScreen:fitOnScreen animated:animated completionHandler:^(id<SJFitOnScreenManager> mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( completionHandler ) completionHandler(self);
    }];
}
@end


#pragma mark - 屏幕旋转

@implementation SJBaseCommonCode (Rotation)

- (void)setRotationManager:(nullable id<SJRotationManager>)rotationManager {
    [self _setupRotationManager:rotationManager];
}

- (nullable id<SJRotationManager>)rotationManager {
    if ( _rotationManager == nil && !self.onlyFitOnScreen ) {
        SJRotationManager *defaultManager = [SJRotationManager rotationManager];
        defaultManager.actionForwarder = self.viewControllerManager;
        [self _setupRotationManager:defaultManager];
    }
    return _rotationManager;
}

- (id<SJRotationManagerObserver>)rotationObserver {
    id<SJRotationManagerObserver> observer = objc_getAssociatedObject(self, _cmd);
    if ( observer == nil ) {
        observer = [self.rotationManager getObserver];
        objc_setAssociatedObject(self, _cmd, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observer;
}

- (void)setShouldTriggerRotation:(BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))shouldTriggerRotation {
    objc_setAssociatedObject(self, @selector(shouldTriggerRotation), shouldTriggerRotation, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (BOOL (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))shouldTriggerRotation {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAllowsRotationInFitOnScreen:(BOOL)allowsRotationInFitOnScreen {
    objc_setAssociatedObject(self, @selector(allowsRotationInFitOnScreen), @(allowsRotationInFitOnScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)allowsRotationInFitOnScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)rotate {
    [self.rotationManager rotate];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated {
    [self.rotationManager rotate:orientation animated:animated];
}

- (void)rotate:(SJOrientation)orientation animated:(BOOL)animated completion:(void (^ _Nullable)(__kindof SJBaseCommonCode *player))block {
    __weak typeof(self) _self = self;
    [self.rotationManager rotate:orientation animated:animated completionHandler:^(id<SJRotationManager>  _Nonnull mgr) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        if ( block ) block(self);
    }];
}

- (BOOL)isRotating {
    return _rotationManager.isRotating;
}

- (BOOL)isFullscreen {
    return _rotationManager.isFullscreen;
}

- (UIInterfaceOrientation)currentOrientation {
    return (NSInteger)_rotationManager.currentOrientation;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    if ( lockedScreen != self.isLockedScreen ) {
        self.viewControllerManager.lockedScreen = lockedScreen;
        objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if      ( lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(lockedCommonCode:)] ) {
            [self.controlLayerDelegate lockedCommonCode:self];
        }
        else if ( !lockedScreen && [self.controlLayerDelegate respondsToSelector:@selector(unlockedCommonCode:)] ) {
            [self.controlLayerDelegate unlockedCommonCode:self];
        }
        
        [self _postNotification:SJCommonCodeScreenLockStateDidChangeNotification];
    }
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
@end



@implementation SJBaseCommonCode (Screenshot)

- (void)setPresentationSizeDidChangeExeBlock:(void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))presentationSizeDidChangeExeBlock {
    objc_setAssociatedObject(self, @selector(presentationSizeDidChangeExeBlock), presentationSizeDidChangeExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))presentationSizeDidChangeExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGSize)videoPresentationSize {
    return _playbackController.presentationSize;
}

- (UIImage * __nullable)screenshot {
    return [_playbackController screenshot];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                completion:(void(^)(__kindof SJBaseCommonCode *commonCode, UIImage * __nullable image, NSError *__nullable error))block {
    [self screenshotWithTime:time size:CGSizeZero completion:block];
}

- (void)screenshotWithTime:(NSTimeInterval)time
                      size:(CGSize)size
                completion:(void(^)(__kindof SJBaseCommonCode *commonCode, UIImage * __nullable image, NSError *__nullable error))block {
    if ( [_playbackController respondsToSelector:@selector(screenshotWithTime:size:completion:)] ) {
        __weak typeof(self) _self = self;
        [(id<SJMTPlaybackScreenshotController>)_playbackController screenshotWithTime:time size:size completion:^(id<SJCommonCodePlaybackController>  _Nonnull controller, UIImage * _Nullable image, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                if ( block ) block(self, image, error);
            });
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseCommonCode<%p>.playbackController does not implement the screenshot method", self]}];
        if ( block ) block(self, nil, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}
@end


#pragma mark - 输出

@implementation SJBaseCommonCode (Export)

- (void)exportWithBeginTime:(NSTimeInterval)beginTime
                    duration:(NSTimeInterval)duration
                 presetName:(nullable NSString *)presetName
                   progress:(void(^)(__kindof SJBaseCommonCode *commonCode, float progress))progressBlock
                 completion:(void(^)(__kindof SJBaseCommonCode *commonCode, NSURL *fileURL, UIImage *thumbnailImage))completion
                    failure:(void(^)(__kindof SJBaseCommonCode *commonCode, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(exportWithBeginTime:duration:presetName:progress:completion:failure:)] ) {
        __weak typeof(self) _self = self;
        [(id<SJMTPlaybackExportController>)_playbackController exportWithBeginTime:beginTime duration:duration presetName:presetName progress:^(id<SJCommonCodePlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJCommonCodePlaybackController>  _Nonnull controller, NSURL * _Nullable fileURL, UIImage * _Nullable thumbImage) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, fileURL, thumbImage);
        } failure:^(id<SJCommonCodePlaybackController>  _Nonnull controller, NSError * _Nullable error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseCommonCode<%p>.playbackController does not implement the exportWithBeginTime:endTime:presetName:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelExportOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelExportOperation)] ) {
        [(id<SJMTPlaybackExportController>)_playbackController cancelExportOperation];
    }
}

- (void)generateGIFWithBeginTime:(NSTimeInterval)beginTime
                        duration:(NSTimeInterval)duration
                        progress:(void(^)(__kindof SJBaseCommonCode *commonCode, float progress))progressBlock
                      completion:(void(^)(__kindof SJBaseCommonCode *commonCode, UIImage *imageGIF, UIImage *thumbnailImage, NSURL *filePath))completion
                         failure:(void(^)(__kindof SJBaseCommonCode *commonCode, NSError *error))failure {
    if ( [_playbackController respondsToSelector:@selector(generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure:)] ) {
        NSURL *filePath = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"SJGeneratedGif.gif"]];
        __weak typeof(self) _self = self;
        [(id<SJMTPlaybackExportController>)_playbackController generateGIFWithBeginTime:beginTime duration:duration maximumSize:CGSizeMake(375, 375) interval:0.1f gifSavePath:filePath progress:^(id<SJCommonCodePlaybackController>  _Nonnull controller, float progress) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( progressBlock ) progressBlock(self, progress);
        } completion:^(id<SJCommonCodePlaybackController>  _Nonnull controller, UIImage * _Nonnull imageGIF, UIImage * _Nonnull screenshot) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( completion ) completion(self, imageGIF, screenshot, filePath);
        } failure:^(id<SJCommonCodePlaybackController>  _Nonnull controller, NSError * _Nonnull error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( failure ) failure(self, error);
        }];
    }
    else {
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{@"errorMsg":[NSString stringWithFormat:@"SJBaseCommonCode<%p>.playbackController does not implement the generateGIFWithBeginTime:duration:maximumSize:interval:gifSavePath:progress:completion:failure: method", self]}];
        if ( failure ) failure(self, error);
#ifdef DEBUG
        printf("%s\n", error.userInfo.description.UTF8String);
#endif
    }
}

- (void)cancelGenerateGIFOperation {
    if ( [_playbackController respondsToSelector:@selector(cancelGenerateGIFOperation)] ) {
        [(id<SJMTPlaybackExportController>)_playbackController cancelGenerateGIFOperation];
    }
}
@end


#pragma mark - 在`tableView`或`collectionView`上播放

@implementation SJBaseCommonCode (ScrollView)

- (void)refreshAppearStateForPlayerView {
    [self.playModelObserver refreshAppearState];
}

- (void)setSmallViewFloatingController:(nullable id<SJSmallViewFloatingController>)smallViewFloatingController {
    [self _setupSmallViewFloatingController:smallViewFloatingController];
}

- (id<SJSmallViewFloatingController>)smallViewFloatingController {
    if ( _smallViewFloatingController == nil ) {
        __weak typeof(self) _self = self;
        SJSmallViewFloatingController *controller = SJSmallViewFloatingController.alloc.init;
        controller.floatingViewShouldAppear = ^BOOL(id<SJSmallViewFloatingController>  _Nonnull controller) {
            __strong typeof(_self) self = _self;
            if ( !self ) return NO;
            return self.timeControlStatus != SJPlaybackTimeControlStatusPaused && self.assetStatus != SJAssetStatusUnknown;
        };
        [self _setupSmallViewFloatingController:controller];
    }
    return _smallViewFloatingController;
}

- (void)setHiddenFloatSmallViewWhenPlaybackFinished:(BOOL)hiddenFloatSmallViewWhenPlaybackFinished {
    _controlInfo->floatSmallViewControl.hiddenFloatSmallViewWhenPlaybackFinished = hiddenFloatSmallViewWhenPlaybackFinished;
}
- (BOOL)isHiddenFloatSmallViewWhenPlaybackFinished {
    return _controlInfo->floatSmallViewControl.hiddenFloatSmallViewWhenPlaybackFinished;
}

- (void)setPausedWhenScrollDisappeared:(BOOL)pausedWhenScrollDisappeared {
    _controlInfo->scrollControl.pausedWhenScrollDisappeared = pausedWhenScrollDisappeared;
}
- (BOOL)pausedWhenScrollDisappeared {
    return _controlInfo->scrollControl.pausedWhenScrollDisappeared;
}

- (void)setHiddenViewWhenScrollDisappeared:(BOOL)hiddenViewWhenScrollDisappeared {
    _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared = hiddenViewWhenScrollDisappeared;
}
- (BOOL)hiddenViewWhenScrollDisappeared {
    return _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared;
}

- (void)setResumePlaybackWhenScrollAppeared:(BOOL)resumePlaybackWhenScrollAppeared {
    _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared = resumePlaybackWhenScrollAppeared;
}
- (BOOL)resumePlaybackWhenScrollAppeared {
    return _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared;
}

- (BOOL)isPlayOnScrollView {
    return self.playModelObserver.isPlayInScrollView;
}

- (BOOL)isScrollAppeared {
    return _controlInfo->scrollControl.isScrollAppeared;
}

- (void)setPlayerViewWillAppearExeBlock:(void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))playerViewWillAppearExeBlock {
    objc_setAssociatedObject(self, @selector(playerViewWillAppearExeBlock), playerViewWillAppearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))playerViewWillAppearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayerViewWillDisappearExeBlock:(void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))playerViewWillDisappearExeBlock {
    objc_setAssociatedObject(self, @selector(playerViewWillDisappearExeBlock), playerViewWillDisappearExeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^_Nullable)(__kindof SJBaseCommonCode * _Nonnull))playerViewWillDisappearExeBlock {
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation SJBaseCommonCode (Subtitles)
- (void)setSubtitlePopupController:(nullable id<SJSubtitlePopupController>)subtitlePopupController {
    [_subtitlePopupController.view removeFromSuperview];
    _subtitlePopupController = subtitlePopupController;
    if ( subtitlePopupController != nil ) {
        subtitlePopupController.view.layer.zPosition = SJBFCodeZIndexes.shared.subtitleViewZIndex;
        [self.presentView addSubview:subtitlePopupController.view];
        [subtitlePopupController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_greaterThanOrEqualTo(self.subtitleHorizontalMinMargin);
            make.right.mas_lessThanOrEqualTo(-self.subtitleHorizontalMinMargin);
            make.centerX.offset(0);
            make.bottom.offset(-self.subtitleBottomMargin);
        }];
    }
}

- (id<SJSubtitlePopupController>)subtitlePopupController {
    if ( _subtitlePopupController == nil ) {
        self.subtitlePopupController = SJSubtitlePopupController.alloc.init;
    }
    return _subtitlePopupController;
}

- (void)setSubtitleBottomMargin:(CGFloat)subtitleBottomMargin {
    objc_setAssociatedObject(self, @selector(subtitleBottomMargin), @(subtitleBottomMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlePopupController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-subtitleBottomMargin);
    }];
}
- (CGFloat)subtitleBottomMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}

- (void)setSubtitleHorizontalMinMargin:(CGFloat)subtitleHorizontalMinMargin {
    objc_setAssociatedObject(self, @selector(subtitleHorizontalMinMargin), @(subtitleHorizontalMinMargin), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.subtitlePopupController.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_greaterThanOrEqualTo(subtitleHorizontalMinMargin);
        make.right.mas_lessThanOrEqualTo(-subtitleHorizontalMinMargin);
    }];
}
- (CGFloat)subtitleHorizontalMinMargin {
    id value = objc_getAssociatedObject(self, _cmd);
    return value != nil ? [value doubleValue] : 22;
}
@end


#pragma mark - 提示

@implementation SJBaseCommonCode (Popup)
- (void)setTextPopupController:(nullable id<SJTextPopupController>)controller {
    objc_setAssociatedObject(self, @selector(textPopupController), controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( controller != nil ) [self _setupTextPopupController:controller];
}

- (id<SJTextPopupController>)textPopupController {
    id<SJTextPopupController> controller = objc_getAssociatedObject(self, _cmd);
    if ( controller == nil ) {
        controller = SJTextPopupController.alloc.init;
        objc_setAssociatedObject(self, _cmd, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self _setupTextPopupController:controller];
    }
    return controller;
}

- (void)_setupTextPopupController:(id<SJTextPopupController>)controller {
    controller.target = self.presentView;
}

- (void)setPromptingPopupController:(nullable id<SJPromptingPopupController>)controller {
    objc_setAssociatedObject(self, @selector(promptingPopupController), controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ( controller != nil ) [self _setupPromptingPopupController:controller];
}

- (id<SJPromptingPopupController>)promptingPopupController {
    id<SJPromptingPopupController>_Nullable controller = objc_getAssociatedObject(self, _cmd);
    if ( controller == nil ) {
        controller = [SJPromptingPopupController new];
        objc_setAssociatedObject(self, _cmd, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self _setupPromptingPopupController:controller];
    }
    return controller;
}

- (void)_setupPromptingPopupController:(id<SJPromptingPopupController>)controller {
    controller.target = self.presentView;
}
@end


@implementation SJBaseCommonCode (Danmaku)
- (void)setDanmakuPopupController:(nullable id<SJDanmakuPopupController>)danmakuPopupController {
    if ( _danmakuPopupController != nil )
        [_danmakuPopupController.view removeFromSuperview];
    
    _danmakuPopupController = danmakuPopupController;
    if ( danmakuPopupController != nil ) {
        danmakuPopupController.view.layer.zPosition = SJBFCodeZIndexes.shared.danmakuViewZIndex;
        [self.presentView addSubview:danmakuPopupController.view];
        [danmakuPopupController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
        }];
    }
}
- (id<SJDanmakuPopupController>)danmakuPopupController {
    id<SJDanmakuPopupController> controller = _danmakuPopupController;
    if ( controller == nil ) {
        controller = [SJDanmakuPopupController.alloc initWithNumberOfTracks:4];
        [self setDanmakuPopupController:controller];
    }
    return controller;
}
@end

@implementation SJBaseCommonCode (Watermark)
 
- (void)setWatermarkView:(nullable UIView<SJWatermarkView> *)watermarkView {
    UIView<SJWatermarkView> *oldView = self.watermarkView;
    if ( oldView != nil ) {
        if ( oldView == watermarkView )
            return;
        
        [oldView removeFromSuperview];
    }

    objc_setAssociatedObject(self, @selector(watermarkView), watermarkView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ( watermarkView != nil ) {
        watermarkView.layer.zPosition = SJBFCodeZIndexes.shared.watermarkViewZIndex;
        [self.presentView addSubview:watermarkView];
        [watermarkView layoutWatermarkInRect:self.presentView.bounds videoPresentationSize:self.videoPresentationSize spGravity:self.spGravity];
    }
}

- (nullable UIView<SJWatermarkView> *)watermarkView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)updateWatermarkViewLayout {
    [self.watermarkView layoutWatermarkInRect:self.presentView.bounds videoPresentationSize:self.videoPresentationSize spGravity:self.spGravity];
}
@end


#pragma mark -

@interface SJBaseCommonCode (SJPlayModelPropertiesObserverDelegate)<SJPlayModelPropertiesObserverDelegate>
@end

@implementation SJBaseCommonCode (SJPlayModelPropertiesObserverDelegate)
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedCollectionView:(BOOL)touched { /* nothing */ }
- (void)observer:(nonnull SJPlayModelPropertiesObserver *)observer userTouchedTableView:(BOOL)touched { /* nothing */ }

- (void)playerWillAppearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer superview:(nonnull UIView *)superview {
    if ( _controlInfo->scrollControl.isScrollAppeared ) {
        return;
    }
    
    _controlInfo->scrollControl.isScrollAppeared = YES;
    _deviceVolumeAndBrightnessTargetViewContext.isScrollAppeared = YES;
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
    
    if ( _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared ) {
        _view.hidden = NO;
    }
    
    if ( _playbackController.isPlayed ) {
        if ( !self.viewControllerManager.isViewDisappeared ) {
            if ( self.isPlayOnScrollView ) {
                if ( _controlInfo->scrollControl.resumePlaybackWhenScrollAppeared ) {
                    [self play];
                }
            }
        }
    }
    
    if ( superview && self.view.superview != superview ) {
        [superview addSubview:self.view];
        [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
    }
    
    if ( _smallViewFloatingController.isAppeared ) {
        [_smallViewFloatingController dismiss];
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCodeWillAppearInScrollView:)] ) {
        [self.controlLayerDelegate commonCodeWillAppearInScrollView:self];
    }
    
    if ( self.playerViewWillAppearExeBlock )
        self.playerViewWillAppearExeBlock(self);
}
- (void)playerWillDisappearForObserver:(nonnull SJPlayModelPropertiesObserver *)observer {
    if ( _controlInfo->scrollControl.isScrollAppeared == NO ) {
        return;
    }
    
    if ( _rotationManager.isRotating )
        return;

    _controlInfo->scrollControl.isScrollAppeared = NO;
    _deviceVolumeAndBrightnessTargetViewContext.isScrollAppeared = NO;
    [_deviceVolumeAndBrightnessController onTargetViewContextUpdated];
    
    _view.hidden = _controlInfo->scrollControl.hiddenPlayerViewWhenScrollDisappeared;
    
    if ( _smallViewFloatingController.isEnabled ) {
        [_smallViewFloatingController show];
    }
    else if ( _controlInfo->scrollControl.pausedWhenScrollDisappeared ) {
        if (@available(iOS 14.0, *)) {
            if ( _playbackController.pictureInPictureStatus != SJPictureInPictureStatusRunning ) {
                [self pause];
            }
        }
        else {
            [self pause];
        }
    }
    
    if ( [self.controlLayerDelegate respondsToSelector:@selector(commonCodeWillDisappearInScrollView:)] ) {
        [self.controlLayerDelegate commonCodeWillDisappearInScrollView:self];
    }
    
    if ( self.playerViewWillDisappearExeBlock )
        self.playerViewWillDisappearExeBlock(self);
}
@end

#pragma mark -

@implementation SJBaseCommonCode (Deprecated)
- (void)playWithURL:(NSURL *)URL {
    self.assetURL = URL;
}
- (void)setAssetURL:(nullable NSURL *)assetURL {
    self.resource = [[SJCommonCodeResource alloc] initWithSource:assetURL];
}

- (nullable NSURL *)assetURL {
    return self.resource.mtSource;
}

- (BOOL)isPlayedToEndTime {
    return self.isPlaybackFinished && self.finishedReason == SJFinishedReasonToEndTimePosition;
}
@end
NS_ASSUME_NONNULL_END
