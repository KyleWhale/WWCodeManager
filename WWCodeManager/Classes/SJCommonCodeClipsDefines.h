//
//  SJCommonCodeClipsDefines.h
//  SJCommonCodeProject
//
//  Created by admin on 2018/4/12.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#ifndef SJCommonCodeClipsDefines_h
#define SJCommonCodeClipsDefines_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class SJClipsControlLayer, SJClipsResultShareItem, SJCommonCodeResource, SJBaseCommonCode;
@protocol SJCommonCodeClipsResult, SJCommonCodeClipsResultUpload;

typedef NS_ENUM(NSUInteger, SJClipsStatus) {
    SJClipsStatus_Unknown,
    SJClipsStatus_Recording,
    SJClipsStatus_Cancelled,
    SJClipsStatus_Paused,
    SJClipsStatus_Finished,
};

typedef NS_ENUM(NSUInteger, SJCommonCodeClipsOperation) {
    SJCommonCodeClipsOperation_Unknown,
    SJCommonCodeClipsOperation_Screenshot,
    SJCommonCodeClipsOperation_Export,
    SJCommonCodeClipsOperation_GIF,
} ;

typedef NS_ENUM(NSUInteger, SJClipsResultUploadState) {
    SJClipsResultUploadStateUnknown,
    SJClipsResultUploadStateUploading,
    SJClipsResultUploadStateFailed,
    SJClipsResultUploadStateSuccessfully,
    SJClipsResultUploadStateCancelled,
} ;

typedef NS_ENUM(NSUInteger, SJClipsExportState) {
    SJClipsExportStateUnknown,
    SJClipsExportStateExporting,
    SJClipsExportStateFailed,
    SJClipsExportStateSuccess,
    SJClipsExportStateCancelled,
} ;

NS_ASSUME_NONNULL_BEGIN
@protocol SJCommonCodeClipsParameters <NSObject>
// operation
@property (nonatomic, readonly) SJCommonCodeClipsOperation operation;
@property (nonatomic, readonly) CMTimeRange range;

// upload
@property (nonatomic) BOOL resultNeedUpload;
@property (nonatomic, weak, nullable) id<SJCommonCodeClipsResultUpload> resultUploader;

// album
@property (nonatomic) BOOL saveResultToAlbum;
@end

@protocol SJCommonCodeClipsResult <NSObject>
@property (nonatomic, readonly) SJCommonCodeClipsOperation operation;
@property (nonatomic, readonly) SJClipsExportState exportState;
@property (nonatomic, readonly) SJClipsResultUploadState uploadState;

/// results
@property (nonatomic, strong, readonly, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, readonly, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, readonly, nullable) NSURL *fileURL;
@property (nonatomic, strong, readonly, nullable) SJCommonCodeResource *currentPlayAsset;
- (NSData * __nullable)data;
@end

@protocol SJCommonCodeClipsResultUpload <NSObject>
- (void)upload:(id<SJCommonCodeClipsResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJCommonCodeClipsResult>)result;
@end
NS_ASSUME_NONNULL_END

#endif /* SJCommonCodeClipsDefines_h */
