//
//  SJCommonCodeURLAssetPrefetcher.m
//  Pods
//
//  Created by 畅三江 on 2019/3/28.
//

#import "SJCommonCodeURLAssetPrefetcher.h"
#import "SJExecuteCodeLoader.h"
#define __SJPrefetchMaxCount  (3)

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeURLAssetPrefetcher ()
@property (nonatomic, strong, readonly) NSMutableArray<SJCommonCodeURLAsset *> *m;
@end

@implementation SJCommonCodeURLAssetPrefetcher
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
- (SJPrefetchIdentifier)prefetchAsset:(SJCommonCodeURLAsset *)asset {
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
- (SJCommonCodeURLAsset *_Nullable)assetForURL:(NSURL *)URL {
    if ( URL ) {
        for ( SJCommonCodeURLAsset *asset in _m ) {
            if ( [asset.mtSource isEqual:URL] )
                return asset;
        }
    }
    return nil;
}
- (SJCommonCodeURLAsset *_Nullable)assetForIdentifier:(SJPrefetchIdentifier)identifier {
    for ( SJCommonCodeURLAsset *asset in _m ) {
        if ( (NSInteger)asset == identifier )
            return asset;
    }
    return nil;
}
- (void)removeAsset:(SJCommonCodeURLAsset *)asset {
    NSInteger idx = [self _indexOfAsset:asset];
    if ( idx != NSNotFound )
        [_m removeObjectAtIndex:idx];
}
- (NSInteger)_indexOfAsset:(SJCommonCodeURLAsset *)asset {
    if (  asset ) {
        for ( NSInteger i = 0 ; i < _m.count ; ++ i ) {
            SJCommonCodeURLAsset *a = _m[i];
            if ( a == asset || [a.mtSource isEqual:asset.mtSource] ) {
                return i;
            }
        }
    }
    return NSNotFound;
}
@end
NS_ASSUME_NONNULL_END
