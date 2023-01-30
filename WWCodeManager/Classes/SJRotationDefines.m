//
//  SJRotationDefines.m
//  SJCommonCode_Example
//
//  Created by admin on 2022/8/13.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJRotationDefines.h"

NSNotificationName const SJRotationManagerRotationNotification = @"SJRotationManagerRotationNotification";
NSNotificationName const SJRotationManagerTransitionNotification = @"SJRotationManagerTransitionNotification";

BOOL
SJRotationIsFullscreenOrientation(SJOrientation orientation) {
    switch (orientation) {
        case SJOrientation_Portrait:
            return NO;
        case SJOrientation_LandscapeLeft:
        case SJOrientation_LandscapeRight:
            return YES;
    }
    return NO;
}

BOOL
SJRotationIsSupportedOrientation(SJOrientation orientation, SJOrientationMask supportedOrientations) {
    return supportedOrientations & (1 << orientation);
}
