//
//  SJClipsVideoCountDownView.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJProgressSlider.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsVideoCountDownView : UIView
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UILabel *promptLabel;
@property (nonatomic, strong, readonly) SJProgressSlider *progressSlider;
@end
NS_ASSUME_NONNULL_END
