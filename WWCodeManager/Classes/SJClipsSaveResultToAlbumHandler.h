//
//  SJClipsSaveResultToAlbumHandler.h
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SJCommonCodeClipsResult;

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJClipsSaveResultToAlbumFailedReason) {
    SJClipsSaveResultToAlbumFailedReasonAuthDenied,
} ;

@protocol SJClipsSaveResultFailed <NSObject>
@property (nonatomic, readonly) SJClipsSaveResultToAlbumFailedReason reason;
- (NSString *)toString;
@end

@protocol SJClipsSaveResultToAlbumHandler <NSObject>
- (void)saveResult:(id<SJCommonCodeClipsResult>)result completionHandler:(void(^)(BOOL r, id<SJClipsSaveResultFailed> failed))completionHandler;
@end

@interface SJClipsSaveResultToAlbumHandler : NSObject<SJClipsSaveResultToAlbumHandler>

@end
NS_ASSUME_NONNULL_END
