//
//  SJPlaybackObservation.m
//  Pods
//
//  Created by admin on 2019/8/27.
//

#import "SJPlaybackObservation.h"
#import "SJBaseCommonCodeConst.h"
#import "SJCommonCodePlayStatusDefines.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackObservation {
    NSMutableArray *_tokens;
}
- (instancetype)initWithPlayer:(__kindof SJBaseCommonCode *)player {
    self = [super init];
    if ( self ) {
        _tokens = NSMutableArray.new;
        _player = player;
        
        __weak typeof(self) _self = self;
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeAssetStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.assetStatusDidChangeExeBlock ) self.assetStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackTimeControlStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.timeControlStatusDidChangeExeBlock ) self.timeControlStatusDidChangeExeBlock(self.player);
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];

        if (@available(iOS 14.0, *)) {
            [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePictureInPictureStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( self.pictureInPictureStatusDidChangeExeBlock ) self.pictureInPictureStatusDidChangeExeBlock(self.player);
            }]];
        }
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackDidFinishNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playbackDidFinishExeBlock ) self.playbackDidFinishExeBlock(self.player);
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            else if ( self.didPlayToEndTimeExeBlock && [(id)self.player valueForKey:@"finishedReason"] == SJFinishedReasonToEndTimePosition ) self.didPlayToEndTimeExeBlock(self.player);
            #pragma clang diagnostic pop
            if ( self.playbackStatusDidChangeExeBlock ) self.playbackStatusDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeDefinitionSwitchStatusDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.definitionSwitchStatusDidChangeExeBlock ) self.definitionSwitchStatusDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeCurrentTimeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.currentTimeDidChangeExeBlock ) self.currentTimeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.durationDidChangeExeBlock ) self.durationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlayableDurationDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playableDurationDidChangeExeBlock ) self.playableDurationDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePresentationSizeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.presentationSizeDidChangeExeBlock ) self.presentationSizeDidChangeExeBlock(self.player);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackTypeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playbackTypeDidChangeExeBlock ) self.playbackTypeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeScreenLockStateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.screenLockStateDidChangeExeBlock ) self.screenLockStateDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeMutedDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.mutedDidChangeExeBlock ) self.mutedDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeVolumeDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.playerVolumeDidChangeExeBlock ) self.playerVolumeDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodeRateDidChangeNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.rateDidChangeExeBlock ) self.rateDidChangeExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackDidReplayNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.didReplayExeBlock ) self.didReplayExeBlock(self.player);
        }]];
        
        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackWillSeekNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.willSeekToTimeExeBlock ) self.willSeekToTimeExeBlock(note.object, [(NSValue *)note.userInfo[SJCommonCodeNotificationUserInfoKeySeekTime] CMTimeValue]);
        }]];

        [_tokens addObject:[NSNotificationCenter.defaultCenter addObserverForName:SJCommonCodePlaybackDidSeekNotification object:player queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            if ( self.didSeekToTimeExeBlock ) self.didSeekToTimeExeBlock(note.object, [(NSValue *)note.userInfo[SJCommonCodeNotificationUserInfoKeySeekTime] CMTimeValue]);
        }]];
    }
    return self;
}

- (void)dealloc {
    for ( id token in _tokens ) {
        [NSNotificationCenter.defaultCenter removeObserver:token];
    }
}
@end
NS_ASSUME_NONNULL_END
