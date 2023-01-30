//
//  SJExecuteCodeLayerView.h
//  Pods
//
//  Created by admin on 2020/2/19.
//

#import <UIKit/UIKit.h>
#import "SJMTPlaybackController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJExecuteCodeLayerView : UIView<SJCodeShowView>
@property (nonatomic, strong, readonly) AVPlayerLayer *layer;
- (void)setScreenshot:(nullable UIImage *)image;
@end

NS_ASSUME_NONNULL_END
