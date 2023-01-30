//
//  SJSPDefinitionSwitchingControlLayer.h
//  Pods
//
//  Created by admin on 2019/7/12.
//

#import "SJEdgeControlLayerAdapters.h"
#import "SJControlLayerDefines.h"
#import "SJCommonCodeResource+SJExtendedDefinition.h"

#pragma mark - 切换清晰度时的控制层

@protocol SJSPDefinitionSwitchingControlLayerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJSPDefinitionSwitchingControlLayer : SJEdgeControlLayerAdapters<SJControlLayer>

@property (nonatomic, copy, nullable) NSArray<SJCommonCodeResource *> *assets;

@property (nonatomic, weak, nullable) id<SJSPDefinitionSwitchingControlLayerDelegate> delegate;

@property (nonatomic, strong, null_resettable) UIColor *selectedTextColor;
@end

@protocol SJSPDefinitionSwitchingControlLayerDelegate <NSObject>

- (void)controlLayer:(SJSPDefinitionSwitchingControlLayer *)controlLayer didSelectAsset:(SJCommonCodeResource *)asset;

- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer;

@end
NS_ASSUME_NONNULL_END
