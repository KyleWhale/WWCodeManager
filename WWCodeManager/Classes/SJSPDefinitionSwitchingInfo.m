//
//  SJSPDefinitionSwitchingInfo.m
//  Pods
//
//  Created by admin on 2019/7/12.
//

#import "SJSPDefinitionSwitchingInfo.h"

NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const _SJSPDefinitionSwitchStatusDidChangeNotification = @"_SJSPDefinitionSwitchStatusDidChangeNotification";

@implementation SJSPDefinitionSwitchingInfoObserver {
    id _token;
}

- (instancetype)initWithInfo:(SJSPDefinitionSwitchingInfo *)info {
    self = [super init];
    if ( self ) {
        __weak typeof(self) _self = self;
        _token = [NSNotificationCenter.defaultCenter addObserverForName:_SJSPDefinitionSwitchStatusDidChangeNotification object:info queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            if ( self.statusDidChangeExeBlock ) self.statusDidChangeExeBlock(note.object);
        }];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:_token];
}
@end

@interface SJSPDefinitionSwitchingInfo ()
@property (nonatomic, weak, nullable) SJCommonCodeResource *currentPlayingAsset;

@property (nonatomic, weak, nullable) SJCommonCodeResource *switchingAsset;

@property (nonatomic) SJDefinitionSwitchStatus status;
@end

@implementation SJSPDefinitionSwitchingInfo
- (SJSPDefinitionSwitchingInfoObserver *)getObserver {
    return [[SJSPDefinitionSwitchingInfoObserver alloc] initWithInfo:self];
}

- (void)setStatus:(SJDefinitionSwitchStatus)status {
    if ( status != _status ) {
        _status = status;
        [NSNotificationCenter.defaultCenter postNotificationName:_SJSPDefinitionSwitchStatusDidChangeNotification object:self];
    }
}
@end
NS_ASSUME_NONNULL_END
