//
//  SJClipsSaveResultToAlbumHandler.m
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJClipsSaveResultToAlbumHandler.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "SJCommonCodeConfigurations.h"
#import "SJCommonCodeClipsDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJClipsSaveResultFailed : NSObject<SJClipsSaveResultFailed>
- (instancetype)initWithReason:(SJClipsSaveResultToAlbumFailedReason)reason;
@end

@implementation SJClipsSaveResultFailed
@synthesize reason = _reason;

- (instancetype)initWithReason:(SJClipsSaveResultToAlbumFailedReason)reason {
    self = [super init];
    if ( !self ) return nil;
    _reason = reason;
    return self;
}

- (NSString *)toString {
    switch ( _reason ) {
        case SJClipsSaveResultToAlbumFailedReasonAuthDenied:
            return SJCommonCodeConfigurations.shared.localizedStrings.albumAuthDeniedPrompt;
    }
}
@end


@interface SJClipsSaveResultToAlbumHandler ()
@property (nonatomic, copy, nullable) void(^completionHandler)(BOOL r, id<SJClipsSaveResultFailed> failed);
@end

@implementation SJClipsSaveResultToAlbumHandler
- (void)saveResult:(id<SJCommonCodeClipsResult>)result completionHandler:(void (^)(BOOL, id<SJClipsSaveResultFailed> _Nonnull))completionHandler {
    _completionHandler = completionHandler;
    
    switch ( result.operation ) {
        case SJCommonCodeClipsOperation_Unknown:
            break;
        case SJCommonCodeClipsOperation_Screenshot: {
            [self _saveScreenshot:result];
        }
            break;
        case SJCommonCodeClipsOperation_Export: {
            [self _saveVideo:result];
        }
            break;
        case SJCommonCodeClipsOperation_GIF: {
            [self _saveGIF:result];
        }
            break;
    }
}

- (void)_saveScreenshot:(id<SJCommonCodeClipsResult>)result {
    UIImageWriteToSavedPhotosAlbum(result.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)_saveGIF:(id<SJCommonCodeClipsResult>)result {
    __weak typeof(self) _self = self;
    if ( @available(iOS 9.0, *) ) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            switch ( status ) {
                case PHAuthorizationStatusNotDetermined:
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied: {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ( self.completionHandler ) self.completionHandler(NO, [[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]);
                    });
                }
                    break;
                case PHAuthorizationStatusLimited:
                case PHAuthorizationStatusAuthorized: {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:result.fileURL];
                    } completionHandler:^(BOOL success, NSError *error) {
                        __strong typeof(_self) self = _self;
                        if ( !self ) return ;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ( self.completionHandler ) self.completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
                        });
                    }];
                }
                    break;
            }
        }];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
        [library writeImageDataToSavedPhotosAlbum:result.data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.completionHandler ) self.completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
            });
        }];
#pragma clang diagnostic pop
    }
}

- (void)_saveVideo:(id<SJCommonCodeClipsResult>)result {
    UISaveVideoAtPathToSavedPhotosAlbum(result.fileURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if ( _completionHandler ) _completionHandler(!error, error?[[SJClipsSaveResultFailed alloc] initWithReason:SJClipsSaveResultToAlbumFailedReasonAuthDenied]:nil);
}

@end
NS_ASSUME_NONNULL_END
