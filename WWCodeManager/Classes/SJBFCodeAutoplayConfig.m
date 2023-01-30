//
//  SJBFCodeAutoplayConfig.m
//  Masonry
//
//  Created by admin on 2018/7/10.
//

#import "SJBFCodeAutoplayConfig.h"

@interface SJBFCodeAutoplayConfig ()
@property (nonatomic) NSInteger playerSuperviewTag __deprecated;
@end

@implementation SJBFCodeAutoplayConfig
+ (instancetype)configWithPlayerSuperviewSelector:(nullable SEL)playerSuperviewSelector autoplayDelegate:(id<SJBFCodeAutoplayDelegate>)delegate {
    NSParameterAssert(delegate != nil);
    
    SJBFCodeAutoplayConfig *config = [[self alloc] init];
    config->_autoplayDelegate = delegate;
    config->_playerSuperviewSelector = playerSuperviewSelector;
    return config;
}
@end


@implementation SJBFCodeAutoplayConfig (SJDeprecated)
+ (instancetype)configWithAutoplayDelegate:(id<SJBFCodeAutoplayDelegate>)autoplayDelegate {
    return [self configWithPlayerSuperviewSelector:NULL autoplayDelegate:autoplayDelegate];
}

+ (instancetype)configWithPlayerSuperviewTag:(NSInteger)playerSuperviewTag
                            autoplayDelegate:(id<SJBFCodeAutoplayDelegate>)autoplayDelegate {
    NSParameterAssert(playerSuperviewTag != 0);
    NSParameterAssert(autoplayDelegate != nil);
    
    SJBFCodeAutoplayConfig *config = [SJBFCodeAutoplayConfig configWithAutoplayDelegate:autoplayDelegate];
    config->_playerSuperviewTag = playerSuperviewTag;
    return config;
}
@end
