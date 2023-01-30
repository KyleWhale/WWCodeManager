//
//  SJClipsButtonContainerView.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJClipsBackButton.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsButtonContainerView : UIView
- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size;
@property (nonatomic, strong, readonly) SJClipsBackButton *button;

@property (nonatomic, copy, nullable) void(^clickedBackButtonExeBlock)(SJClipsButtonContainerView *view);
@end
NS_ASSUME_NONNULL_END
