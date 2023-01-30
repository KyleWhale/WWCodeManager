//
//  SJCommonCodeResource.m
//  SJCommonCodeProject
//
//  Created by admin on 2018/1/29.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import "SJCommonCodeResource.h"
#import <objc/message.h>
#if __has_include(<SJUIKit/NSObject+SJObserverHelper.h>)
#import <SJUIKit/NSObject+SJObserverHelper.h>
#else
#import "NSObject+SJObserverHelper.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeResourceObserver : NSObject<SJCommonCodeResourceObserver>
- (instancetype)initWithAsset:(SJCommonCodeResource *)asset;
@end
@implementation SJCommonCodeResourceObserver
@synthesize playModelDidChangeExeBlock = _playModelDidChangeExeBlock;

- (instancetype)initWithAsset:(SJCommonCodeResource *)asset {
    self = [super init];
    if ( !self ) return nil;
    [asset sj_addObserver:self forKeyPath:@"playModel"];
    return self;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( _playModelDidChangeExeBlock ) _playModelDidChangeExeBlock(object);
}
@end

@implementation SJCommonCodeResource
@synthesize mtSource = _mtSource;

- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition playModel:(__kindof SJPlayModel *)playModel {
    if ( !URL ) return nil;
    self = [super init];
    if ( !self ) return nil;
    _mtSource = URL;
    _startPosition = startPosition;
    _playModel = playModel?:[SJPlayModel new];
    _isSpecial = [_mtSource.pathExtension containsString:@"m3u8"];
    return self;
}
- (nullable instancetype)initWithSource:(NSURL *)URL startPosition:(NSTimeInterval)startPosition {
    return [self initWithSource:URL startPosition:startPosition playModel:[SJPlayModel new]];
}
- (nullable instancetype)initWithSource:(NSURL *)URL playModel:(__kindof SJPlayModel *)playModel {
    return [self initWithSource:URL startPosition:0 playModel:playModel];
}
- (nullable instancetype)initWithSource:(NSURL *)URL {
    return [self initWithSource:URL startPosition:0];
}
- (void)setMediaURL:(nullable NSURL *)mtSource {
    _mtSource = mtSource;
    _isSpecial = [mtSource.pathExtension containsString:@"m3u8"];
}
- (SJPlayModel *)playModel {
    if ( _playModel )
        return _playModel;
    return _playModel = [SJPlayModel new];
}
- (id<SJCommonCodeResourceObserver>)getObserver {
    return [[SJCommonCodeResourceObserver alloc] initWithAsset:self];
}
@end
NS_ASSUME_NONNULL_END
