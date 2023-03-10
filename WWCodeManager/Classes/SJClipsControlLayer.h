//
//  SJClipsControlLayer.h
//  SJCommonCode
//
//  Created by admin on 2019/1/19.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJCommonCodeClipsConfig.h"
#import "SJControlLayerDefines.h"

#pragma mark - 剪辑(GIF, Export, Screenshot)控制层


NS_ASSUME_NONNULL_BEGIN
@interface SJClipsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, copy, nullable) void(^cancelledOperationExeBlock)(SJClipsControlLayer *control);
@property (nonatomic, strong, nullable) SJCommonCodeClipsConfig *config;
@end
NS_ASSUME_NONNULL_END
