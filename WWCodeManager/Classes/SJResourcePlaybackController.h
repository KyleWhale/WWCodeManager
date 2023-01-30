//
//  SJResourcePlaybackController.h
//  Pods
//
//  Created by admin on 2020/2/18.
//

#import "SJMTPlaybackController.h"
#import "SJExecuteCode.h"
#import "SJExecuteCodeLayerView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJResourcePlaybackController : SJMTPlaybackController

@property (nonatomic, strong, readonly, nullable) SJExecuteCode *currentPlayer;
@property (nonatomic, strong, readonly, nullable) SJExecuteCodeLayerView *currentPlayerView;
@property (nonatomic) BOOL accurateSeeking;

@end

@interface SJResourcePlaybackController (SJResourcePlaybackAdd)<SJMTPlaybackExportController, SJMTPlaybackScreenshotController>

@end
NS_ASSUME_NONNULL_END
