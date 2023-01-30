//
//  SJBaseCommonCode+TestLog.m
//  SJBaseCommonCode
//
//  Created by admin on 2019/9/11.
//

#ifdef SJDEBUG
#import "SJBaseCommonCode+TestLog.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJBaseCommonCode (TestLog)
- (void)showLog_TimeControlStatus {
    SJPlaybackTimeControlStatus status = self.timeControlStatus;
    NSString *statusStr = nil;
    switch ( status ) {
        case SJPlaybackTimeControlStatusPaused: {
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.TimeControlStatus.Paused\n", self];
        }
            break;
        case SJPlaybackTimeControlStatusWaitingToPlay: {
            NSString *reasonStr = nil;
            if      ( self.reasonForWaitingToPlay == SJWaitingToMinimizeStallsReason ) {
                reasonStr = @"WaitingToMinimizeStallsReason";
            }
            else if ( self.reasonForWaitingToPlay == SJWaitingWhileEvaluatingBufferingRateReason ) {
                reasonStr = @"WaitingWhileEvaluatingBufferingRateReason";
            }
            else if ( self.reasonForWaitingToPlay == SJWaitingWithNoAssetToPlayReason ) {
                reasonStr = @"WaitingWithNoAssetToPlayReason";
            }
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.TimeControlStatus.WaitingToPlay(Reason: %@)\n", self, reasonStr];
        }
            break;
        case SJPlaybackTimeControlStatusPlaying: {
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.TimeControlStatus.Playing\n", self];
        }
            break;
    }
    
    printf("%s", statusStr.UTF8String);
}
- (void)showLog_AssetStatus {
    SJAssetStatus status = self.assetStatus;
    NSString *statusStr = nil;
    switch ( status ) {
        case SJAssetStatusUnknown:
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.assetStatus.Unknown\n", self];
            break;
        case SJAssetStatusPreparing:
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.assetStatus.Preparing\n", self];
            break;
        case SJAssetStatusReadyToPlay:
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.assetStatus.ReadyToPlay\n", self];
            break;
        case SJAssetStatusFailed:
            statusStr = [NSString stringWithFormat:@"SJBaseCommonCode<%p>.assetStatus.Failed\n", self];
            break;
    }
    
    printf("%s", statusStr.UTF8String);
}
@end
NS_ASSUME_NONNULL_END
#endif
