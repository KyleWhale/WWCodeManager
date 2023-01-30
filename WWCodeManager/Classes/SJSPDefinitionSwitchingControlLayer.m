//
//  SJSPDefinitionSwitchingControlLayer.m
//  Pods
//
//  Created by admin on 2019/7/12.
//

#import "SJSPDefinitionSwitchingControlLayer.h"
#if __has_include(<SJUIKit/SJAttributesFactory.h>)
#import <SJUIKit/SJAttributesFactory.h>
#else
#import "SJAttributesFactory.h"
#endif

#if __has_include(<SJBaseCommonCode/SJBaseCommonCode.h>)
#import <SJBaseCommonCode/SJBaseCommonCode.h>
#else
#import "SJBaseCommonCode.h"
#endif

#import "UIView+SJAnimationAdded.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJSPDefinitionSwitchingControlLayer ()
@property (nonatomic, weak, nullable) SJBaseCommonCode *commonCode;
@property (nonatomic, copy, nullable) NSArray<SJEdgeControlButtonItem *> *items;
@end

@implementation SJSPDefinitionSwitchingControlLayer
@synthesize restarted = _restarted;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        self.rightWidth = 140;
        self.rightContainerView.sjv_disappearDirection = SJViewDisappearAnimation_Right;
        self.rightContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    return self;
}

- (UIView *)controlView {
    return self;
}

- (void)installedControlViewToCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    _commonCode = commonCode;
    
    sj_view_initializes(self.rightContainerView);
    
    [self layoutIfNeeded];
    
    sj_view_makeDisappear(self.rightContainerView, NO);
}

- (void)exitControlLayer {
    _restarted = NO;
    
    sj_view_makeDisappear(self.rightContainerView, YES);
    sj_view_makeDisappear(self.controlView, YES, ^{
        if ( !self->_restarted ) [self.controlView removeFromSuperview];
    });
}

- (void)restartControlLayer {
    _restarted = YES;
    
    if ( self.commonCode.isFullscreen )
        [self.commonCode needHiddenStatusBar];
    [self _refreshItems];
    [self.rightAdapter reload];
    sj_view_makeAppear(self.controlView, YES);
    sj_view_makeAppear(self.rightContainerView, YES);
}

- (void)controlLayerNeedAppear:(__kindof SJBaseCommonCode *)commonCode { }

- (void)controlLayerNeedDisappear:(__kindof SJBaseCommonCode *)commonCode { }

- (BOOL)commonCode:(__kindof SJBaseCommonCode *)commonCode gestureRecognizerShouldTrigger:(SJBFCodeGestureType)type location:(CGPoint)location {
    if ( type == SJBFCodeGestureType_SingleTap ) {
        if ( !CGRectContainsPoint(self.rightContainerView.frame, location) ) {
            if ( [self.delegate respondsToSelector:@selector(tappedBlankAreaOnTheControlLayer:)] ) {
                [self.delegate tappedBlankAreaOnTheControlLayer:self];
            }
        }
    }
    return NO;
}

- (BOOL)canTriggerRotationOfCommonCode:(__kindof SJBaseCommonCode *)commonCode {
    return NO;
}

- (void)_clickedItem:(SJEdgeControlButtonItem *)item {
    if ( [self.delegate respondsToSelector:@selector(controlLayer:didSelectAsset:)] ) {
        [self.delegate controlLayer:self didSelectAsset:self.assets[item.tag]];
    }
}

#pragma mark -

- (UIColor *)selectedTextColor {
   if ( _selectedTextColor == nil )
       return UIColor.orangeColor;
    
    return _selectedTextColor;
}

- (void)setAssets:(nullable NSArray<SJCommonCodeResource *> *)assets {
    _assets = assets.copy;
    [self.rightAdapter removeAllItems];
    NSMutableArray<SJEdgeControlButtonItem *> *m = [NSMutableArray new];
    [_assets enumerateObjectsUsingBlock:^(SJCommonCodeResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SJEdgeControlButtonItem *item = [SJEdgeControlButtonItem placeholderWithSize:38 tag:idx];
        [item addAction:[SJEdgeControlButtonItemAction actionWithTarget:self action:@selector(_clickedItem:)]];
        [m addObject:item];
    }];
    self.items = m;
    [self _refreshItems];
    [self.rightAdapter addItemsFromArray:self.items];
    [self.rightAdapter reload];
}

- (void)_refreshItems {
    SJCommonCodeResource *_Nullable cur = _commonCode.resource;
    if ( cur != nil ) {
        SJSPDefinitionSwitchingInfo *info = _commonCode.definitionSwitchingInfo;
        SJCommonCodeResource *selected = cur;
        if ( info.switchingAsset != nil &&
             info.status != SJDefinitionSwitchStatusFailed ) {
            selected = info.switchingAsset;
        }
        
        for ( SJEdgeControlButtonItem *item in self.items ) {
            SJCommonCodeResource *asset = self.assets[item.tag];
            item.title = [NSAttributedString sj_UIKitText:^(id<SJUIKitTextMakerProtocol>  _Nonnull make) {
                make.append([NSString stringWithFormat:@"%@", asset.definition_fullName]);
                make.font([UIFont systemFontOfSize:14]);
                make.alignment(NSTextAlignmentCenter);
                
                UIColor *textColor = asset == selected ? self.selectedTextColor : UIColor.whiteColor;
                make.textColor(textColor);
            }];
        }
    }
}
@end
NS_ASSUME_NONNULL_END
