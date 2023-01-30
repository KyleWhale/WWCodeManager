//
//  SJCommonCodePresentViewDefines.h
//  SJBaseCommonCode
//
//  Created by admin on 2019/9/10.
//

#ifndef SJCommonCodePresentViewDefines_h
#define SJCommonCodePresentViewDefines_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJCommonCodePresentView <NSObject>
@property (nonatomic, strong, readonly) UIImageView *placeholderImageView;
@property (nonatomic, readonly, getter=isPlaceholderImageViewHidden) BOOL placeholderImageViewHidden;

@property (nonatomic) UIViewContentMode placeholderImageViewContentMode; // default value is UIViewContentModeScaleAspectFill;

- (void)setPlaceholderImageViewHidden:(BOOL)isHidden animated:(BOOL)animated;
- (void)hidePlaceholderImageViewAnimated:(BOOL)animated delay:(NSTimeInterval)secs;
@end
NS_ASSUME_NONNULL_END
#endif /* SJCommonCodePresentViewDefines_h */
