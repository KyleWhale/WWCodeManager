//
//  SJBFCodeView.h
//  Pods
//
//  Created by admin on 2019/3/28.
//

#import <UIKit/UIKit.h>

@protocol SJBFCodeViewDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJBFCodeView : UIView
@property (nonatomic, strong, readonly, nullable) UIView *presentView;
@property (nonatomic, weak, nullable) id<SJBFCodeViewDelegate> delegate;
@end

@protocol SJBFCodeViewDelegate <NSObject>
- (void)playerViewWillMoveToWindow:(SJBFCodeView *)codeView;
- (nullable UIView *)codeView:(SJBFCodeView *)codeView hitTestForView:(nullable __kindof UIView *)view;
@end
NS_ASSUME_NONNULL_END
