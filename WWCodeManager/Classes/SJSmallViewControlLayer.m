//
//  SJSmallViewControlLayer.m
//  Pods
//
//  Created by admin on 2019/6/6.
//

#import "SJSmallViewControlLayer.h"
#import "UIView+SJAnimationAdded.h"
#import "SJCommonCodeConfigurations.h"
#if __has_include(<SJBaseCommonCode/SJBaseCommonCode.h>)
#import <SJBaseCommonCode/SJBaseCommonCode.h>
#else
#import "SJBaseCommonCode.h" 
#endif

NS_ASSUME_NONNULL_BEGIN
SJEdgeControlButtonItemTag const SJSmallViewControlLayerTopItem_Close = 10000;

@interface SJSmallViewControlLayer ()
@property (nonatomic, weak, nullable) __kindof SJBaseCommonCode *player;
@end

@implementation SJSmallViewControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    _player = commonCode;
}

- (void)restartControlLayer {
    _restarted = YES;
    sj_view_makeAppear(self.controlView, YES);
}

- (void)exitControlLayer {
    _restarted = NO;
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (void)tappedCloseItem:(SJEdgeControlButtonItem *)item {
    [self.player pauseForUser];
    [self.player.smallViewFloatingController dismiss];
}

- (void)_setupView {
    self.topMargin = 0;
    self.topHeight = 35;
    
    SJEdgeControlButtonItem *fillItem = [[SJEdgeControlButtonItem alloc] initWithTag:0];
    fillItem.fill = YES;
    [self.topAdapter addItem:fillItem];
    
    SJEdgeControlButtonItem *closeItem = [SJEdgeControlButtonItem placeholderWithType:SJButtonItemPlaceholderType_49x49 tag:SJSmallViewControlLayerTopItem_Close];
    [closeItem addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(tappedCloseItem:)]];
    closeItem.image = SJCommonCodeConfigurations.shared.resources.floatSmallViewCloseImage;
    [self.topAdapter addItem:closeItem];
    
    [self.topAdapter reload];
}

- (void)controlLayerNeedAppear:(__kindof SJBaseCommonCode *)commonCode { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseCommonCode *)commonCode { }

- (BOOL)canTriggerRotationOfCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    return NO;
}
@end
NS_ASSUME_NONNULL_END
