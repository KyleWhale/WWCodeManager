//
//  SJClipsResultsControlLayer.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJCommonCodeClipsDefines.h"
#import "SJControlLayerDefines.h"

@class SJClipsResultShareItem;

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsResultsControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>
@property (nonatomic, strong, nullable) NSArray<SJClipsResultShareItem *> *shareItems;
@property (nonatomic, strong, nullable) id<SJCommonCodeClipsParameters> parameters;

@property (nonatomic, copy, nullable) void(^cancelledOperationExeBlock)(SJClipsResultsControlLayer *control);
@property (nonatomic, copy, nullable) void(^clickedResultShareItemExeBlock)(__kindof SJBaseCommonCode *player, SJClipsResultShareItem * item, id<SJCommonCodeClipsResult> result);
@end
NS_ASSUME_NONNULL_END
