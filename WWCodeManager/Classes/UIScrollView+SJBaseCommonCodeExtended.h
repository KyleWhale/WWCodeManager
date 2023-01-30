//
//  UIScrollView+SJBaseCommonCodeExtended.h
//  SJBaseCommonCode
//
//  Created by admin on 2019/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (SJBaseCommonCodeExtended)

- (nullable __kindof UIView *)viewWithTag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isViewAppearedWithTag:(NSInteger)tag insets:(UIEdgeInsets)insets atIndexPath:(NSIndexPath *)indexPath;

- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag atIndexPath:(NSIndexPath *)indexPath;
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag inHeaderForSection:(NSInteger)section;
- (nullable __kindof UIView *)viewWithProtocol:(Protocol *)protocol tag:(NSInteger)tag inFooterForSection:(NSInteger)section;
- (BOOL)isViewAppearedWithProtocol:(Protocol *)protocol tag:(NSInteger)tag insets:(UIEdgeInsets)insets atIndexPath:(NSIndexPath *)indexPath;

- (nullable __kindof UIView *)viewForSelector:(SEL)selector atIndexPath:(NSIndexPath *)indexPath;
- (nullable __kindof UIView *)viewForSelector:(SEL)selector inHeaderForSection:(NSInteger)section;
- (nullable __kindof UIView *)viewForSelector:(SEL)selector inFooterForSection:(NSInteger)section;
- (BOOL)isViewAppearedForSelector:(SEL)selector insets:(UIEdgeInsets)insets atIndexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
