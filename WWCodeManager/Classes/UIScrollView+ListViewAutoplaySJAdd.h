//
//  UIScrollView+ListViewAutoplaySJAdd.h
//  Masonry
//
//  Created by admin on 2018/7/9.
//

#import <UIKit/UIKit.h>
#import "SJBFCodeAutoplayConfig.h"

NS_ASSUME_NONNULL_BEGIN

///
/// List view autoplay.
/// 列表自动播放功能
/// v1.3.0 新增
///
@interface UIScrollView (ListViewAutoplaySJAdd)

@property (nonatomic, readonly) BOOL sj_enabledAutoplay;

///
/// enable autoplay
/// 开启
///
- (void)sj_enableAutoplayWithConfig:(SJBFCodeAutoplayConfig *)autoplayConfig;

///
/// 关闭
///
- (void)sj_disableAutoplay;

///
/// 移除当前播放视图
///
- (void)sj_removeCurrentPlayerView;
@end


/// Developers don't need to care, this category is automatically maintained by the SJBaseCommonCode.
/// 开发者无需关心, 此分类由播放器自动维护
@interface UIScrollView (SJAutoplayPlayerAssigns)
@property (nonatomic, strong, nullable, readonly) NSIndexPath *sj_currentPlayingIndexPath;
- (void)setSj_currentPlayingIndexPath:(nullable NSIndexPath *)sj_currentPlayingIndexPath;
@end
NS_ASSUME_NONNULL_END
