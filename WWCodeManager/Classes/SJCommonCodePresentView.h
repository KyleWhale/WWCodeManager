//
//  SJCommonCodePresentView.h
//  SJCommonCodeProject
//
//  Created by admin on 2017/11/29.
//  Copyright © 2017年 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCommonCodePresentViewDefines.h"
#import "SJGestureControllerDefines.h"
@protocol SJCommonCodePresentViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodePresentView : UIView<SJCommonCodePresentView, SJGestureController>
@property (nonatomic, weak, nullable) id<SJCommonCodePresentViewDelegate> delegate;
@end

@protocol SJCommonCodePresentViewDelegate <NSObject>
@optional
- (void)presentViewDidLayoutSubviews:(SJCommonCodePresentView *)presentView;
- (void)presentViewDidMoveToWindow:(SJCommonCodePresentView *)presentView;
@end
NS_ASSUME_NONNULL_END
