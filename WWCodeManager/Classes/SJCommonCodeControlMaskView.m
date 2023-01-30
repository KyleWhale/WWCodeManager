//
//  SJCommonCodeControlMaskView.m
//  SJCommonCodeProject
//
//  Created by admin on 2017/9/25.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import "SJCommonCodeControlMaskView.h"

@interface SJCommonCodeControlMaskView ()

@property (nonatomic, assign, readwrite) SJMaskStyle style;

@end

@implementation SJCommonCodeControlMaskView
+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (instancetype)initWithStyle:(SJMaskStyle)style {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    self.style = style;
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    switch (_style) {
        case SJMaskStyle_top: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor,
                                         (__bridge id)[UIColor clearColor].CGColor];
        }
            break;
        case SJMaskStyle_bottom: {
            maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                         (__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor];
        }
            break;
    }
    return self;
}

- (void)cleanColors {
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    maskGradientLayer.colors = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
