//
//  SJCommonCode.h
//  SJCommonCodeProject
//
//  Created by admin on 2018/5/29.
//  Copyright © 2018年 admin. All rights reserved.
//
//  GitHub:     https://github.com/changsanjiang/SJBaseCommonCode
//  GitHub:     https://github.com/changsanjiang/SJCommonCode
//
//  Email:      changsanjiang@gmail.com
//  QQGroup:    930508201
//

#if __has_include(<SJBaseCommonCode/SJBaseCommonCode.h>)
#import <SJBaseCommonCode/SJBaseCommonCode.h>
#else
#import "SJBaseCommonCode.h"
#endif
#import "SJControlLayerIdentifiers.h"
#import "SJCommonCodeConfigurations.h"
#import "SJCommonCodeResource+SJControlAdd.h"
#import "SJCommonCodeClipsDefines.h"
#import "SJCommonCodeClipsConfig.h"
#import "SJControlLayerSwitcher.h"

#import "SJEdgeControlLayer.h"
#import "SJClipsControlLayer.h"
#import "SJMoreSettingControlLayer.h"
#import "SJLoadFailedControlLayer.h"
#import "SJNotReachableControlLayer.h"
#import "SJSmallViewControlLayer.h"
#import "SJSPDefinitionSwitchingControlLayer.h"
#import "SJCommonCodeResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCode : SJBaseCommonCode

///
/// 使用默认的控制层
///
+ (instancetype)shared;

///
/// A lightweight player with simple functions.
///
/// 一个具有简单功能的播放器.
///
+ (instancetype)lightweightCode;

- (instancetype)init;

///
/// v2.0.8
///
/// 新增: 控制层 切换器, 管理控制层的切换
///
@property (nonatomic, strong, readonly) SJControlLayerSwitcher *switcher;

// - 以下为各种状态下的播放器控制层, 均为懒加载 -

///
/// 默认的边缘控制层
///
///         当需要在竖屏隐藏返回按钮时, 可以设置`player.defaultEdgeControlLayer.hiddenBackButtonWhenOrientationIsPortrait = YES`
///         更多配置, 请前往该控制层头文件查看
///
@property (nonatomic, strong, readonly) SJEdgeControlLayer *defaultEdgeControlLayer;

///
/// 默认的无网状态下显示的控制层
///
@property (nonatomic, strong, readonly) SJNotReachableControlLayer *defaultNotReachableControlLayer;

///
/// 默认的剪辑(GIF, Export, Screenshot)控制层
///
@property (nonatomic, strong, readonly) SJClipsControlLayer *defaultClipsControlLayer;

///
/// 默认的`more setting`控制层(调整音量/亮度/速率)
///
@property (nonatomic, strong, readonly) SJMoreSettingControlLayer *defaultMoreSettingControlLayer;

///
/// 默认的加载失败或播放出错时显示的控制层
///
@property (nonatomic, strong, readonly) SJLoadFailedControlLayer *defaultLoadFailedControlLayer;

///
/// 默认的小浮窗模式下的控制层
///
@property (nonatomic, strong, readonly) SJSmallViewControlLayer *defaultSmallViewControlLayer;

///
/// 默认的切换清晰度时的控制层
///
@property (nonatomic, strong, readonly) SJSPDefinitionSwitchingControlLayer *defaultVideoDefinitionSwitchingControlLayer;


- (instancetype)_init;
+ (NSString *)version;
@end

@interface SJCommonCode (CommonSettings)
///
/// Note: The `block` runs on the sub thread.
///
/// \code
///    SJCommonCode.updateResources(^(id<SJCommonCodeControlLayerResources>  _Nonnull resources) {
///        resources.placeholder = [UIImage imageNamed:@"placeholder"];
///        resources.progressThumbSize = 8;
///        resources.progressTrackColor = [UIColor colorWithWhite:0.8 alpha:1];
///        resources.progressBufferColor = [UIColor whiteColor];
///    });
/// \endcode
@property (class, nonatomic, copy, readonly) void(^updateResources)(void(^block)(id<SJCommonCodeControlLayerResources> resources));
@property (class, nonatomic, copy, readonly) void(^updateLocalizedStrings)(void(^block)(id<SJCommonCodeLocalizedStrings> strings));
@property (class, nonatomic, copy, readonly) void(^setLocalizedStrings)(NSBundle *bundle);
///
/// Note: The `block` runs on the sub thread.
///
/// \code
///     SJCommonCode.update(^(SJCommonCodeConfigurations * _Nonnull commonSettings) {
///         // 注意, 该block将在子线程执行
///         configs.resources.backImage = [UIImage imageNamed:@"icon_back"];
///         configs.resources.placeholder = [UIImage imageNamed:@"placeholder"];
///         configs.resources.progressTrackColor = [UIColor colorWithWhite:0.4 alpha:1];
///     });
/// \endcode
///
@property (class, nonatomic, copy, readonly) void(^update)(void(^block)(SJCommonCodeConfigurations *configs));
@end


@interface SJCommonCode (SJExtendedVideoDefinitionSwitchingControlLayer)

///
/// 切换清晰度
///
/// \code
///
///     SJCommonCodeResource *asset1 = [[SJCommonCodeResource alloc] initWithSource:VideoURL_Level4];
///     asset1.definition_fullName = @"超清 1080P";
///     asset1.definition_lastName = @"超清";
///
///     SJCommonCodeResource *asset2 = [[SJCommonCodeResource alloc] initWithSource:VideoURL_Level3];
///     asset2.definition_fullName = @"高清 720P";
///     asset2.definition_lastName = @"AAAAAAA";
///
///     SJCommonCodeResource *asset3 = [[SJCommonCodeResource alloc] initWithSource:VideoURL_Level2];
///     asset3.definition_fullName = @"清晰 480P";
///     asset3.definition_lastName = @"480P";
///
///     // 1. 配置清晰度资源
///     _player.definitionResources = @[asset1, asset2, asset3];
///
///     // 2. 先播放asset1 (asset2 和 asset3 将会在用户选择后进行切换)
///     _player.resource = asset1;
///
/// \endcode
///
@property (nonatomic, copy, nullable) NSArray<SJCommonCodeResource *> *definitionResources;

/// 切换清晰度时, 是否关掉切换进度的提示
///
///     default value is NO.
///
@property (nonatomic, getter=isDisabledDefinitionSwitchingPrompt) BOOL disabledDefinitionSwitchingPrompt;

@end
 

@interface SJCommonCode (RotationOrFitOnScreen)
///
/// 当视频`宽 > 高`时, 将执行 Rotation(旋转至横屏全屏) 相关方法.
///
/// 当视频`宽 < 高`时, 将执行 FitOnScreen(竖屏全屏) 相关方法.
///
///     - Rotation: 播放器视图将会在横屏(全屏)与竖屏(小屏)之间切换
///
///     - FitOnScreen: 播放器视图将会在竖屏全屏与竖屏小屏之间切换
///
@property (nonatomic) BOOL automaticallyPerformRotationOrFitOnScreen;

///
/// 处于小屏时, 当点击全屏按钮后, 是否先竖屏撑满全屏.
///
@property (nonatomic) BOOL needsFitOnScreenFirst;

@end


@interface SJEdgeControlLayer (SJCommonCodeExtended)
///
/// 是否在Top栏上显示`more item`(三个点). default value is YES
///
/// 如果需要关闭, 可以设置: player.defaultEdgeControlLayer.showsMoreItem = NO;
///
@property (nonatomic) BOOL showsMoreItem;

///
/// 是否开启剪辑功能
///         - 默认是NO
///         - 不支持剪辑m3u8(如果开启, 将会自动隐藏剪辑按钮)
///
@property (nonatomic, getter=isEnabledClips) BOOL enabledClips;

///
/// 剪辑功能配置
///
@property (nonatomic, strong, null_resettable) SJCommonCodeClipsConfig *clipsConfig;

@end

@interface SJCommonCode (SJExtendedControlLayerSwitcher)

///
/// 切换控制层
///
- (void)switchControlLayerForIdentifier:(SJControlLayerIdentifier)identifier;
@end
NS_ASSUME_NONNULL_END
