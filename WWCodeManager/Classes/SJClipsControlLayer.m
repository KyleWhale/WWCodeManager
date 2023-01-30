//
//  SJClipsControlLayer.m
//  SJCommonCode
//
//  Created by admin on 2019/1/19.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJClipsControlLayer.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJBaseCommonCode/SJBaseCommonCode.h>)
#import <SJBaseCommonCode/SJBaseCommonCode.h>
#else
#import "SJBaseCommonCode.h"  
#endif
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#import "UIView+SJAnimationAdded.h"

// control layers
#import "SJClipsGIFRecordsControlLayer.h"
#import "SJClipsVideoRecordsControlLayer.h"
#import "SJClipsResultsControlLayer.h"

#import "SJCommonCodeClipsParameters.h"
#import "SJControlLayerSwitcher.h"
#import "SJCommonCodeConfigurations.h"

#import "SJEdgeControlButtonItemInternal.h"

NS_ASSUME_NONNULL_BEGIN
// right items
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_Screenshot = 10000;
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_ExportVideo = 10001;
static SJEdgeControlButtonItemTag SJClipsControlLayerRightItem_ExportGIF = 10002;

// control layer
static SJControlLayerIdentifier SJClipsGIFRecordsControlLayerIdentifier = 1;
static SJControlLayerIdentifier SJClipsVideoRecordsControlLayerIdentifier = 2;
static SJControlLayerIdentifier SJClipsResultsControlLayerIdentifier = 3;

@interface SJClipsControlLayer ()
@property (nonatomic, strong, nullable) SJControlLayerSwitcher *switcher;
@property (nonatomic, weak, nullable) __kindof SJBaseCommonCode *player;
@end

@implementation SJClipsControlLayer 
@synthesize restarted = _restarted;

- (void)restartControlLayer {
    _restarted = YES;
    
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.controlView, YES);
    sj_view_makeDisappear(self.rightContainerView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupViews];
    }
    return self;
}

- (void)screenshotItemWasTapped {
    [self _start:SJCommonCodeClipsOperation_Screenshot];
}

- (void)exportVideoItemWasTapped {
    [self _start:SJCommonCodeClipsOperation_Export];
}

- (void)exportGIFItemWasTapped {
    [self _start:SJCommonCodeClipsOperation_GIF];
}

- (void)_start:(SJCommonCodeClipsOperation)operation {
    if ( _player.assetStatus != SJAssetStatusReadyToPlay ) {
        [self.player.textPopupController show:[NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
            make.append(SJCommonCodeConfigurations.shared.localizedStrings.operationFailedPrompt);
            make.textColor(UIColor.whiteColor);
        }]];
        return;
    }
    
    if ( ![self _shouldStart:operation] ) {
        return;
    }

    switch ( operation ) {
        case SJCommonCodeClipsOperation_Unknown:
            break;
        case SJCommonCodeClipsOperation_Screenshot:
            [self _showResultsWithParameters:[self _parametersWithOperation:SJCommonCodeClipsOperation_Screenshot range:kCMTimeRangeZero]];
            break;
        case SJCommonCodeClipsOperation_Export:
            [self.switcher switchControlLayerForIdentifier:SJClipsVideoRecordsControlLayerIdentifier];
            break;
        case SJCommonCodeClipsOperation_GIF:
            [self.switcher switchControlLayerForIdentifier:SJClipsGIFRecordsControlLayerIdentifier];
            break;
    }
}

- (void)cancel {
//    [[self.switcher controlLayerForIdentifier:self.switcher.currentIdentifier] exitControlLayer];
    _switcher = nil;
    if ( self.cancelledOperationExeBlock ) {
        self.cancelledOperationExeBlock(self);
    }
}

- (SJCommonCodeClipsParameters *)_parametersWithOperation:(SJCommonCodeClipsOperation)operation range:(CMTimeRange)range {
    SJCommonCodeClipsParameters *parameters = [[SJCommonCodeClipsParameters alloc] initWithOperation:operation range:range];
    parameters.resultUploader = self.config.resultUploader;
    parameters.resultNeedUpload = self.config.resultNeedUpload;
    parameters.saveResultToAlbum = self.config.saveResultToAlbum;
    return parameters;
}

- (void)_showResultsWithParameters:(id<SJCommonCodeClipsParameters>)parameters {
    [_player pause];
    
    [self.switcher switchControlLayerForIdentifier:SJClipsResultsControlLayerIdentifier];
    SJClipsResultsControlLayer *control = (id)[self.switcher controlLayerForIdentifier:SJClipsResultsControlLayerIdentifier];
    control.parameters = parameters;
    control.shareItems = self.config.resultShareItems;
    control.clickedResultShareItemExeBlock = self.config.clickedResultShareItemExeBlock;
}
#pragma mark -

- (void)_setupViews {
    self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
    sj_view_initializes(@[self.rightContainerView]);
    
    [self _addItemToRightAdapter];
    [self _updateRightItemSettings];
}

- (void)_addItemToRightAdapter {
    SJEdgeControlButtonItem *screenshotItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_Screenshot];
    [screenshotItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(screenshotItemWasTapped)]];
    [self.rightAdapter addItem:screenshotItem];
    
    SJEdgeControlButtonItem *exportVideoItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_ExportVideo];
    [exportVideoItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(exportVideoItemWasTapped)]];
    [self.rightAdapter addItem:exportVideoItem];
    
    SJEdgeControlButtonItem *exportGIFItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJClipsControlLayerRightItem_ExportGIF];
    [exportGIFItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(exportGIFItemWasTapped)]];
    [self.rightAdapter addItem:exportGIFItem];
}

- (void)_updateRightItemSettings {
    id<SJCommonCodeControlLayerResources> sources = SJCommonCodeConfigurations.shared.resources;
    SJEdgeControlButtonItem *screenshotItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_Screenshot];
    screenshotItem.image = sources.screenshotImage;
    screenshotItem.innerHidden = _config.disableScreenshot;
    
    SJEdgeControlButtonItem *exportVideoItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_ExportVideo];
    exportVideoItem.image = sources.videoClipImage;
    exportVideoItem.innerHidden = _config.disableRecord;
    
    SJEdgeControlButtonItem *exportGIFItem = [self.rightAdapter itemForTag:SJClipsControlLayerRightItem_ExportGIF];
    exportGIFItem.image = sources.GIFClipImage;
    exportGIFItem.innerHidden = _config.disableGIF;
    
    [self.rightAdapter reload];
}

- (void)_initializeSwitcher:(__kindof SJBaseCommonCode *)commonCode {
    _switcher = [[SJControlLayerSwitcher alloc] initWithPlayer:commonCode];
    __weak typeof(self) _self = self;
    _switcher.resolveControlLayer = ^id<SJControlLayer> _Nullable(SJControlLayerIdentifier identifier) {
        __strong typeof(_self) self = _self;
        if ( !self ) return nil;
        if ( identifier == SJClipsGIFRecordsControlLayerIdentifier ) {
            SJClipsGIFRecordsControlLayer *controlLayer = [SJClipsGIFRecordsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJClipsGIFRecordsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJClipsStatus_Unknown:
                    case SJClipsStatus_Recording:
                    case SJClipsStatus_Paused:
                        break;
                    case SJClipsStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJClipsStatus_Finished: {
                        [self _showResultsWithParameters:[self _parametersWithOperation:SJCommonCodeClipsOperation_GIF range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJClipsVideoRecordsControlLayerIdentifier ) {
            SJClipsVideoRecordsControlLayer *controlLayer = [SJClipsVideoRecordsControlLayer new];
            controlLayer.statusDidChangeExeBlock = ^(SJClipsVideoRecordsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                switch ( control.status ) {
                    case SJClipsStatus_Unknown:
                    case SJClipsStatus_Recording:
                    case SJClipsStatus_Paused:
                        break;
                    case SJClipsStatus_Cancelled: {
                        [self cancel];
                    }
                        break;
                    case SJClipsStatus_Finished: {
                        [self _showResultsWithParameters:[self _parametersWithOperation:SJCommonCodeClipsOperation_Export range:control.range]];
                    }
                        break;
                }
            };
            return controlLayer;
        }
        else if ( identifier == SJClipsResultsControlLayerIdentifier ) {
            SJClipsResultsControlLayer *controlLayer = [SJClipsResultsControlLayer new];
            controlLayer.cancelledOperationExeBlock = ^(SJClipsResultsControlLayer * _Nonnull control) {
                __strong typeof(_self) self = _self;
                if ( !self ) return ;
                [self cancel];
            };
            return controlLayer;
        }

        return nil;
    };
}

- (void)setConfig:(nullable SJCommonCodeClipsConfig *)config {
    _config = config;
    [self _updateRightItemSettings];
}

#pragma mark -

- (BOOL)_shouldStart:(SJCommonCodeClipsOperation)operation {
    if ( _config.shouldStart != nil ) {
        return _config.shouldStart(self.player, operation);
    }
    return YES;
}


#pragma mark -

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    _player = commonCode;
    [commonCode needHiddenStatusBar];
    [self _initializeSwitcher:commonCode];
    sj_view_makeDisappear(self.rightContainerView, NO);
}

- (BOOL)canTriggerRotationOfCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    return NO;
}

- (BOOL)commonCode:(__kindof SJBaseCommonCode *)commonCode gestureRecognizerShouldTrigger:(SJBFCodeGestureType)type location:(CGPoint)location {
    if ( type == SJBFCodeGestureType_SingleTap ) {
        if ( ![self.rightAdapter itemContainsPoint:location] ) {
            if ( _cancelledOperationExeBlock )
                _cancelledOperationExeBlock(self);
        }
    }
    return NO;
}
- (void)controlLayerNeedAppear:(__kindof SJBaseCommonCode *)commonCode { }
- (void)controlLayerNeedDisappear:(__kindof SJBaseCommonCode *)commonCode { }
@end
NS_ASSUME_NONNULL_END
