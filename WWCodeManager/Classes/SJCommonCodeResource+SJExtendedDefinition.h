//
//  SJCommonCodeResource+SJExtendedDefinition.h
//  Pods
//
//  Created by admin on 2019/7/12.
//

#if __has_include(<SJBaseCommonCode/SJCommonCodeResource.h>)
#import <SJBaseCommonCode/SJCommonCodeResource.h>
#else
#import "SJCommonCodeResource.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SJCommonCodeResource (SJExtendedDefinition)

/// e.g. 高清 720P
@property (nonatomic, copy, nullable) NSString *definition_fullName;

/// e.g. 720P
@property (nonatomic, copy, nullable) NSString *definition_lastName;

@end

NS_ASSUME_NONNULL_END
