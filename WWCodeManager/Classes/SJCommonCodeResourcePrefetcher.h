//
//  SJCommonCodeResourcePrefetcher.h
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeResource.h"

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
///        SJCommonCodeResource *asset = [[SJCommonCodeResource alloc] initWithSource:URL];
///        [SJCommonCodeResourcePrefetcher.shared prefetchAsset:asset];
///    }
///
///    // - 2. 从`Prefetcher`中获取, 如果为空, 则创建一个新的资源进行播放
///    - (void)playDemo {
///        NSURL *URL = [NSURL URLWithString:@"..."];
///        SJCommonCodeResource *asset = [SJCommonCodeResourcePrefetcher.shared assetForURL:URL];
///        if ( !asset ) {
///            asset = [[SJCommonCodeResource alloc] initWithSource:URL];
///        }
///        _player.resource = asset;
///    }
/// \endcode
@interface SJCommonCodeResourcePrefetcher : NSObject
+ (instancetype)shared;
@property (nonatomic) NSUInteger maxCount; // default value is 3;

- (SJPrefetchIdentifier)prefetchAsset:(SJCommonCodeResource *)asset;
- (SJCommonCodeResource *_Nullable)assetForURL:(NSURL *)URL;
- (SJCommonCodeResource *_Nullable)assetForIdentifier:(SJPrefetchIdentifier)identifier;
- (void)removeAsset:(SJCommonCodeResource *)asset;
@end
NS_ASSUME_NONNULL_END
