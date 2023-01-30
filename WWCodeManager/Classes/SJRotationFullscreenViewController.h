//
//  SJRotationFullscreenViewController.h
//  SJCommonCode_Example
//
//  Created by admin on 2022/8/14.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJRotationFullscreenViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJRotationFullscreenViewController : UIViewController
@property (nonatomic, weak, nullable) id<SJRotationFullscreenViewControllerDelegate> delegate;
@end

@protocol SJRotationFullscreenViewControllerDelegate <NSObject>
- (UIStatusBarStyle)preferredStatusBarStyleForRotationFullscreenViewController:(SJRotationFullscreenViewController *)viewController;
- (BOOL)prefersStatusBarHiddenForRotationFullscreenViewController:(SJRotationFullscreenViewController *)viewController;
@end
NS_ASSUME_NONNULL_END
