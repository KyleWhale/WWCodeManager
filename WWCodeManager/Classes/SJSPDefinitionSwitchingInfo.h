//
//  SJSPDefinitionSwitchingInfo.h
//  Pods
//
//  Created by admin on 2019/7/12.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeResource.h"
#import "SJCommonCodePlaybackControllerDefines.h"
@class SJSPDefinitionSwitchingInfoObserver;

NS_ASSUME_NONNULL_BEGIN

@interface SJSPDefinitionSwitchingInfo : NSObject

- (SJSPDefinitionSwitchingInfoObserver *)getObserver;

@property (nonatomic, weak, readonly, nullable) SJCommonCodeResource *currentPlayingAsset;

@property (nonatomic, weak, readonly, nullable) SJCommonCodeResource *switchingAsset;

@property (nonatomic, readonly) SJDefinitionSwitchStatus status;

@end



@interface SJSPDefinitionSwitchingInfoObserver: NSObject

@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJSPDefinitionSwitchingInfo *info);

@end

NS_ASSUME_NONNULL_END
