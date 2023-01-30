//
//  SJExecuteCodeLayerView.m
//  Pods
//
//  Created by admin on 2020/2/19.
//

#import "SJExecuteCodeLayerView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJExecuteCodeLayerView ()
@property (nonatomic, strong) CALayer *screenshotLayer;
@end

@implementation SJExecuteCodeLayerView
@dynamic layer;

+ (Class)layerClass {
    return AVPlayerLayer.class;
}

static NSString *kReadyForDisplay = @"readyForDisplay";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew;
        [self.layer addObserver:self forKeyPath:kReadyForDisplay options:ops context:&kReadyForDisplay];
        
        _screenshotLayer = [CALayer.alloc init];
        [self.layer addSublayer:_screenshotLayer];
    }
    return self;
}

- (BOOL)isReadyForDisplay {
    return self.layer.isReadyForDisplay;
}

- (void)setSpGravity:(SJSPGravity)spGravity {
    self.layer.videoGravity = spGravity;
    if      ( spGravity == AVLayerVideoGravityResize ) {
        _screenshotLayer.contentsGravity = kCAGravityResize;
    }
    else if ( spGravity == AVLayerVideoGravityResizeAspect ) {
        _screenshotLayer.contentsGravity = kCAGravityResizeAspect;
    }
    else if ( spGravity == AVLayerVideoGravityResizeAspectFill ) {
        _screenshotLayer.contentsGravity = kCAGravityResizeAspectFill;
    }
}

- (SJSPGravity)spGravity {
    return self.layer.videoGravity;
}

- (void)setScreenshot:(nullable UIImage *)image {
    _screenshotLayer.contents = image != nil ? (__bridge id)(image.CGImage) : nil;
}

- (void)dealloc {
    [self.layer removeObserver:self forKeyPath:kReadyForDisplay];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    if ( context == &kReadyForDisplay ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:SJCodeShowViewReadyForDisplayNotification object:self];
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _screenshotLayer.frame = self.bounds;
}
@end
NS_ASSUME_NONNULL_END
