//
//  SJPlaybackRecordSaveHandler.m
//  SJCommonCode_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)

#import "SJPlaybackRecordSaveHandler.h"
#import <objc/message.h>
#import "SJBaseCommonCodeConst.h"
#import "SJBaseCommonCode.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPlaybackRecordSaveHandler {
    SJBFCodeEventObserver *_observer;
    id<SJPlaybackHistoryController> _controller;
}

+ (instancetype)shared {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [SJPlaybackRecordSaveHandler.alloc initWithEvents:SJBFCodeEventMaskAll playbackHistoryController:SJPlaybackHistoryController.shared];
    });
    return obj;
}

- (instancetype)initWithEvents:(SJBFCodeEventMask)events playbackHistoryController:(id<SJPlaybackHistoryController>)controller;
 {
    self = [super init];
    if ( self ) {
        _controller = controller;
        __weak typeof(self) _self = self;
        _observer = [SJBFCodeEventObserver.alloc initWithEvents:events handler:^(id  _Nonnull target, SJBFCodeEvent event) {
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            [self _target:target event:event];
        }];
    }
    return self;
}

- (void)setEvents:(SJBFCodeEventMask)events {
    _observer.events = events;
}

- (SJBFCodeEventMask)events {
    return _observer.events;
}

- (void)_target:(id)target event:(SJBFCodeEvent)event {
    switch ( event ) {
        case SJBFCodeEventPlaybackDidPause: {
            SJBaseCommonCode *player = target;
            if ( player.isPaused ) {
                [self _saveForPlayer:player];
            }
        }
            break;
        case SJBFCodeEventPlaybackWillRefresh:
        case SJBFCodeEventResourceWillChange:
        case SJBFCodeEventPlaybackWillStop:
        case SJBFCodeEventApplicationDidEnterBackground:
        case SJBFCodeEventApplicationWillTerminate:
            [self _saveForPlayer:target];
            break;
        case SJBFCodeEventPlaybackControllerWillDeallocate:
            [self _saveForPlaybackController:target];
            break;
    }
}

- (void)_saveForPlayer:(SJBaseCommonCode *)player {
    SJPlaybackRecord *record = player.resource.record;
    if ( record != nil ) {
        record.position = player.currentTime;
        [self _saveRecord:record];
    }
}

- (void)_saveForPlaybackController:(id<SJCommonCodePlaybackController>)playbackController {
    SJPlaybackRecord *record = ((SJCommonCodeResource *)playbackController.media).record;
    if ( record != nil ) {
        record.position = playbackController.currentTime;
        [self _saveRecord:record];
    }
}

- (void)_saveRecord:(SJPlaybackRecord *)record {
    [_controller save:record];
#ifdef DEBUG
    NSLog(@"%d \t %s \t 已保存播放位置: %lf", (int)__LINE__, __func__, record.position);
#endif
}
@end

@implementation SJCommonCodeResource (SJPlaybackRecordSaveHandlerExtended)
- (void)setRecord:(nullable SJPlaybackRecord *)record {
    objc_setAssociatedObject(self, @selector(record), record, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (nullable SJPlaybackRecord *)record {
    return objc_getAssociatedObject(self, _cmd);
}
@end


@implementation SJBFCodeEventObserver {
    void(^_block)(id target, SJBFCodeEvent event);
}
- (instancetype)initWithEvents:(SJBFCodeEventMask)events handler:(void(^)(id target, SJBFCodeEvent event))block {
    self = [super init];
    if ( self ) {
        _events = events;
        _block = block;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_timeControlStatusDidChange:) name:SJCommonCodePlaybackTimeControlStatusDidChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_ResourceWillChange:) name:SJCommonCodeResourceWillChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackWillStop:) name:SJCommonCodePlaybackWillStopNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackWillRefresh:) name:SJCommonCodePlaybackWillRefreshNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEnterBackground:) name:SJCommonCodeApplicationDidEnterBackgroundNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_willTerminate:) name:SJCommonCodeApplicationWillTerminateNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_playbackControllerWillDeallocate:) name:SJCommonCodePlaybackControllerWillDeallocateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)_timeControlStatusDidChange:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskPlaybackDidPause ) {
        SJBaseCommonCode *player = note.object;
        if ( player.isPaused ) {
            if ( _block ) _block(player, SJBFCodeEventPlaybackDidPause);
        }
    }
}

- (void)_ResourceWillChange:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskResourceWillChange ) {
        if ( _block ) _block(note.object, SJBFCodeEventResourceWillChange);
    }
}

- (void)_playbackWillStop:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskPlaybackWillStop ) {
        if ( _block ) _block(note.object, SJBFCodeEventPlaybackWillStop);
    }
}

- (void)_playbackWillRefresh:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskPlaybackWillRefresh ) {
        if ( _block ) _block(note.object, SJBFCodeEventPlaybackWillRefresh);
    }
}

- (void)_didEnterBackground:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskApplicationDidEnterBackground ) {
        if ( _block ) _block(note.object, SJBFCodeEventApplicationDidEnterBackground);
    }
}

- (void)_willTerminate:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskApplicationWillTerminate ) {
        if ( _block ) _block(note.object, SJBFCodeEventApplicationWillTerminate);
    }
}

- (void)_playbackControllerWillDeallocate:(NSNotification *)note {
    if ( _events & SJBFCodeEventMaskPlaybackControllerWillDeallocate ) {
        if ( _block ) _block(note.object, SJBFCodeEventPlaybackControllerWillDeallocate);
    }
}
@end
NS_ASSUME_NONNULL_END

#endif
