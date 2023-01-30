//
//  SJCommonCodeClipsGeneratedResult.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJCommonCodeClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJCommonCodeClipsGeneratedResult : NSObject<SJCommonCodeClipsResult>
@property (nonatomic) SJCommonCodeClipsOperation operation;
@property (nonatomic) SJClipsExportState exportState;
@property (nonatomic) float exportProgress;
@property (nonatomic) SJClipsResultUploadState uploadState;
@property (nonatomic) float uploadProgress;

// results
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJCommonCodeResource *currentPlayAsset;
- (NSData * __nullable)data;

@property (nonatomic, copy, nullable) void(^exportProgressDidChangeExeBlock)(SJCommonCodeClipsGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadProgressDidChangeExeBlock)(SJCommonCodeClipsGeneratedResult *result);

@property (nonatomic, copy, nullable) void(^exportStateDidChangeExeBlock)(SJCommonCodeClipsGeneratedResult *result);
@property (nonatomic, copy, nullable) void(^uploadStateDidChangeExeBlock)(SJCommonCodeClipsGeneratedResult *result);
@end
NS_ASSUME_NONNULL_END
