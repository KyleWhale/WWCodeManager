//
//  SJGestureControllerDefines.h
//  Pods
//
//  Created by admin on 2019/1/3.
//

#ifndef SJGestureControllerProtocol_h
#define SJGestureControllerProtocol_h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJBFCodeGestureType) {
    /// 单击手势
    SJBFCodeGestureType_SingleTap,
    /// 双击手势
    SJBFCodeGestureType_DoubleTap,
    /// 移动手势
    SJBFCodeGestureType_Pan,
    /// 捏合手势
    SJBFCodeGestureType_Pinch,
    /// 长按手势
    SJBFCodeGestureType_LongPress,
};

typedef NS_OPTIONS(NSUInteger, SJBFCodeGestureTypeMask) {
    SJBFCodeGestureTypeMask_None,
    SJBFCodeGestureTypeMask_SingleTap   = 1 << SJBFCodeGestureType_SingleTap,
    SJBFCodeGestureTypeMask_DoubleTap   = 1 << SJBFCodeGestureType_DoubleTap,
    SJBFCodeGestureTypeMask_Pan_H       = 0x100, // 水平方向
    SJBFCodeGestureTypeMask_Pan_V       = 0x200, // 垂直方向
    SJBFCodeGestureTypeMask_Pan         = SJBFCodeGestureTypeMask_Pan_H | SJBFCodeGestureTypeMask_Pan_V,
    SJBFCodeGestureTypeMask_Pinch       = 1 << SJBFCodeGestureType_Pinch,
    SJBFCodeGestureTypeMask_LongPress   = 1 << SJBFCodeGestureType_LongPress,
    
    
    SJBFCodeGestureTypeMask_Default = SJBFCodeGestureTypeMask_SingleTap | SJBFCodeGestureTypeMask_DoubleTap | SJBFCodeGestureTypeMask_Pan | SJBFCodeGestureTypeMask_Pinch,
    SJBFCodeGestureTypeMask_All = SJBFCodeGestureTypeMask_Default | SJBFCodeGestureTypeMask_LongPress,
};

/// 移动方向
typedef NS_ENUM(NSUInteger, SJPanGestureMovingDirection) {
    SJPanGestureMovingDirection_H,
    SJPanGestureMovingDirection_V,
};
 
/// 移动手势触发时的位置
typedef NS_ENUM(NSUInteger, SJPanGestureTriggeredPosition) {
    SJPanGestureTriggeredPosition_Left,
    SJPanGestureTriggeredPosition_Right,
};

/// 移动手势的状态
typedef NS_ENUM(NSUInteger, SJPanGestureRecognizerState) {
    SJPanGestureRecognizerStateBegan,
    SJPanGestureRecognizerStateChanged,
    SJPanGestureRecognizerStateEnded,
};

/// 长按手势的状态
typedef NS_ENUM(NSUInteger, SJLongPressGestureRecognizerState) {
    SJLongPressGestureRecognizerStateBegan,
    SJLongPressGestureRecognizerStateChanged,
    SJLongPressGestureRecognizerStateEnded,
};

@protocol SJGestureController <NSObject>
@property (nonatomic) SJBFCodeGestureTypeMask supportedGestureTypes; ///< default value is .Default
@property (nonatomic, copy, nullable) BOOL(^gestureRecognizerShouldTrigger)(id<SJGestureController> control, SJBFCodeGestureType type, CGPoint location);
@property (nonatomic, copy, nullable) void(^singleTapHandler)(id<SJGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^doubleTapHandler)(id<SJGestureController> control, CGPoint location);
@property (nonatomic, copy, nullable) void(^panHandler)(id<SJGestureController> control, SJPanGestureTriggeredPosition position, SJPanGestureMovingDirection direction, SJPanGestureRecognizerState state, CGPoint translate);
@property (nonatomic, copy, nullable) void(^pinchHandler)(id<SJGestureController> control, CGFloat scale);
@property (nonatomic, copy, nullable) void(^longPressHandler)(id<SJGestureController> control, SJLongPressGestureRecognizerState state);

- (void)cancelGesture:(SJBFCodeGestureType)type;
- (UIGestureRecognizerState)stateOfGesture:(SJBFCodeGestureType)type;

@property (nonatomic, readonly) SJPanGestureMovingDirection movingDirection;
@property (nonatomic, readonly) SJPanGestureTriggeredPosition triggeredPosition;
@end
NS_ASSUME_NONNULL_END

#endif /* SJGestureControllerProtocol_h */
