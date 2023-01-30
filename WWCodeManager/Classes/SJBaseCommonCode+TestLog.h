//
//  SJBaseCommonCode+TestLog.h
//  SJBaseCommonCode
//
//  Created by admin on 2019/9/11.
//

#ifdef SJDEBUG
#import "SJBaseCommonCode.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseCommonCode (TestLog)
- (void)showLog_TimeControlStatus;
- (void)showLog_AssetStatus;
@end
NS_ASSUME_NONNULL_END
#endif
