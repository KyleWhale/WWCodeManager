//
//  SJSPDefinitionSwitchingInfo+Private.h
//  Pods
//
//  Created by admin on 2019/7/12.
//

#import "SJSPDefinitionSwitchingInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJSPDefinitionSwitchingInfo (Private)
@property (nonatomic, weak, nullable) SJCommonCodeResource *currentPlayingAsset;

@property (nonatomic, weak, nullable) SJCommonCodeResource *switchingAsset;

@property (nonatomic) SJDefinitionSwitchStatus status;
@end

NS_ASSUME_NONNULL_END
