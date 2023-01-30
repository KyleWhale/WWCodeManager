//
//  SJCommonCodeURLAssetPrefetcher.h
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeURLAsset.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSInteger SJPrefetchIdentifier;

/// - 资源 预加载 -
///
/// 最多预加载`prefetcher.maxCount`个. 当超出时, 将会移除先前的.
///
/// \code
///    // - 1. 进行预加载
///    - (void)prefetchDemo {
///        NSURL *URL = [NSURL URLWithString:@"..."];
///        SJCommonCodeURLAsset *asset = [[SJCommonCodeURLAsset alloc] initWithSource:URL];
///        [SJCommonCodeURLAssetPrefetcher.shared prefetchAsset:asset];
///    }
///
///    // - 2. 从`Prefetcher`中获取, 如果为空, 则创建一个新的资源进行播放
///    - (void)playDemo {
///        NSURL *URL = [NSURL URLWithString:@"..."];
///        SJCommonCodeURLAsset *asset = [SJCommonCodeURLAssetPrefetcher.shared assetForURL:URL];
///        if ( !asset ) {
///            asset = [[SJCommonCodeURLAsset alloc] initWithSource:URL];
///        }
///        _player.URLAsset = asset;
///    }
/// \endcode
@interface SJCommonCodeURLAssetPrefetcher : NSObject
+ (instancetype)shared;
@property (nonatomic) NSUInteger maxCount; // default value is 3;

- (SJPrefetchIdentifier)prefetchAsset:(SJCommonCodeURLAsset *)asset;
- (SJCommonCodeURLAsset *_Nullable)assetForURL:(NSURL *)URL;
- (SJCommonCodeURLAsset *_Nullable)assetForIdentifier:(SJPrefetchIdentifier)identifier;
- (void)removeAsset:(SJCommonCodeURLAsset *)asset;
@end
NS_ASSUME_NONNULL_END
