//
//  SJCommonCodeClipsGeneratedResult.m
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJCommonCodeClipsGeneratedResult.h"

@implementation SJCommonCodeClipsGeneratedResult

- (NSData * _Nullable)data {
    if ( self.fileURL )
        return [NSData dataWithContentsOfURL:self.fileURL];
    else if ( self.image )
        return UIImagePNGRepresentation(self.image);
    return nil;
}

- (void)setExportState:(SJClipsExportState)exportState {
    if ( exportState == _exportState )
     return;
    _exportState = exportState;
    if ( _exportStateDidChangeExeBlock ) _exportStateDidChangeExeBlock(self);
}

- (void)setExportProgress:(float)exportProgress {
    _exportProgress = exportProgress;
    if ( _exportProgressDidChangeExeBlock ) _exportProgressDidChangeExeBlock(self);
}

- (void)setUploadState:(SJClipsResultUploadState)uploadState {
    if ( uploadState == _uploadState )
        return;
    _uploadState = uploadState;
    if ( _uploadStateDidChangeExeBlock ) _uploadStateDidChangeExeBlock(self);
}

- (void)setUploadProgress:(float)uploadProgress {
    _uploadProgress = uploadProgress;
    if ( _uploadProgressDidChangeExeBlock ) _uploadProgressDidChangeExeBlock(self);
}

@end
