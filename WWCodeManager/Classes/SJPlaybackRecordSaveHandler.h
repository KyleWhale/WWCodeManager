//
//  SJPlaybackRecordSaveHandler.h
//  SJCommonCode_Example
//
//  Created by BlueDancer on 2020/2/20.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#if __has_include(<YYModel/YYModel.h>) || __has_include(<YYKit/YYKit.h>)

// 播放记录保存管理类

#import <Foundation/Foundation.h>
#import "SJPlaybackHistoryController.h"
typedef NS_ENUM(NSUInteger, SJBFCodeEvent) {
    ///
    /// 播放器资源将要改变时
    ///
    SJBFCodeEventResourceWillChange,
    ///
    /// 播放控制将要销毁前
    ///
    SJBFCodeEventPlaybackControllerWillDeallocate,
    ///
    /// 播放器执行了暂停
    ///
    SJBFCodeEventPlaybackDidPause,
    ///
    /// 播放器将要执行stop前
    ///
    SJBFCodeEventPlaybackWillStop,
    ///
    /// 播放器将要执行refresh前
    ///
    SJBFCodeEventPlaybackWillRefresh,
    
    
    ///
    /// 播放器接收到App进入后台时
    ///
    SJBFCodeEventApplicationDidEnterBackground,
    ///
    /// 播放器接收到App将要销毁时
    ///
    SJBFCodeEventApplicationWillTerminate,
};

typedef NS_OPTIONS(NSUInteger, SJBFCodeEventMask) {
    SJBFCodeEventMaskResourceWillChange = 1 << SJBFCodeEventResourceWillChange,
    
    SJBFCodeEventMaskPlaybackControllerWillDeallocate = 1 << SJBFCodeEventPlaybackControllerWillDeallocate,
    SJBFCodeEventMaskPlaybackDidPause = 1 << SJBFCodeEventPlaybackDidPause,
    SJBFCodeEventMaskPlaybackWillStop = 1 << SJBFCodeEventPlaybackWillStop,
    SJBFCodeEventMaskPlaybackWillRefresh = 1 << SJBFCodeEventPlaybackWillRefresh,
    
    SJBFCodeEventMaskApplicationDidEnterBackground = 1 << SJBFCodeEventApplicationDidEnterBackground,
    SJBFCodeEventMaskApplicationWillTerminate = 1 << SJBFCodeEventApplicationWillTerminate,
    
    SJBFCodeEventMaskPlaybackEvents = SJBFCodeEventMaskPlaybackControllerWillDeallocate | SJBFCodeEventMaskPlaybackWillStop | SJBFCodeEventMaskPlaybackWillRefresh | SJBFCodeEventMaskPlaybackDidPause,
    
    SJBFCodeEventMaskApplicationEvents = SJBFCodeEventMaskApplicationDidEnterBackground | SJBFCodeEventMaskApplicationWillTerminate,
    
    SJBFCodeEventMaskAll = (SJBFCodeEventMaskResourceWillChange | SJBFCodeEventMaskPlaybackEvents | SJBFCodeEventMaskApplicationEvents),
};
 
NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeResource (SJPlaybackRecordSaveHandlerExtended)
@property (nonatomic, strong, nullable) SJPlaybackRecord *record;
@end


@interface SJPlaybackRecordSaveHandler : NSObject
+ (instancetype)shared;
- (instancetype)initWithEvents:(SJBFCodeEventMask)events playbackHistoryController:(id<SJPlaybackHistoryController>)controller;

/// 设置保存的时机(当发生某个事件之后, handler内部会自动保存播放记录)
@property (nonatomic) SJBFCodeEventMask events;
@end


@interface SJBFCodeEventObserver : NSObject
- (instancetype)initWithEvents:(SJBFCodeEventMask)events handler:(void(^)(id target, SJBFCodeEvent event))block;
@property (nonatomic) SJBFCodeEventMask events;
@end
NS_ASSUME_NONNULL_END

#endif
