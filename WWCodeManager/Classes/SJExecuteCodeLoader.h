//
//  SJExecuteCodeLoader.h
//  Pods
//
//  Created by admin on 2019/4/10.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeResource.h"
#import "SJExecuteCode.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJExecuteCodeLoader : NSObject

+ (nullable SJExecuteCode *)loadPlayerForMedia:(SJCommonCodeResource *)media;

+ (void)clearPlayerForMedia:(SJCommonCodeResource *)media;

@end
NS_ASSUME_NONNULL_END
