//
//  SJCommonCodeClipsParameters.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJCommonCodeClipsParameters : NSObject<SJCommonCodeClipsParameters>
- (instancetype)initWithOperation:(SJCommonCodeClipsOperation)operation range:(CMTimeRange)range;
@end

NS_ASSUME_NONNULL_END
