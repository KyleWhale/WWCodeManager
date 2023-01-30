//
//  SJCommonCodeResourcePrefetcher.m
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import "SJCommonCodeResourcePrefetcher.h"
#import "SJExecuteCodeLoader.h"
#define __SJPrefetchMaxCount  (3)

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeResourcePrefetcher ()
@property (nonatomic, strong, readonly) NSMutableArray<SJCommonCodeResource *> *m;
@end

@implementation SJCommonCodeResourcePrefetcher
+ (instancetype)shared {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
    });
    return _instance;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _maxCount = 3;
    _m = [NSMutableArray array];
    return self;
}
- (SJPrefetchIdentifier)prefetchAsset:(SJCommonCodeResource *)asset {
    if ( asset ) {
        NSInteger idx = [self _indexOfAsset:asset];
        if ( idx == NSNotFound ) {
            if ( _m.count > _maxCount ) {
                [_m removeObjectAtIndex:0];
            }
            // load asset
            [SJExecuteCodeLoader loadPlayerForMedia:asset];
            [_m addObject:asset];
        }
    }
    return (NSInteger)asset;
}
- (SJCommonCodeResource *_Nullable)assetForURL:(NSURL *)URL {
    if ( URL ) {
        for ( SJCommonCodeResource *asset in _m ) {
            if ( [asset.mtSource isEqual:URL] )
                return asset;
        }
    }
    return nil;
}
- (SJCommonCodeResource *_Nullable)assetForIdentifier:(SJPrefetchIdentifier)identifier {
    for ( SJCommonCodeResource *asset in _m ) {
        if ( (NSInteger)asset == identifier )
            return asset;
    }
    return nil;
}
- (void)removeAsset:(SJCommonCodeResource *)asset {
    NSInteger idx = [self _indexOfAsset:asset];
    if ( idx != NSNotFound )
        [_m removeObjectAtIndex:idx];
}
- (NSInteger)_indexOfAsset:(SJCommonCodeResource *)asset {
    if (  asset ) {
        for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
            SJCommonCodeResource *a = _m[i];
            if ( a == asset || [a.mtSource isEqual:asset.mtSource] ) {
                return i;
            }
        }
    }
    return NSNotFound;
}
@end
NS_ASSUME_NONNULL_END
