//
//  SJCommonCodeClipsParameters.m
//  SJCommonCode
//
//  Created by admin on 2019/1/20.
//  Copyright © 2019 admin. All rights reserved.
//

#import "SJCommonCodeClipsParameters.h"

@implementation SJCommonCodeClipsParameters
@synthesize operation = _operation;
@synthesize range = _range;
@synthesize resultNeedUpload = _resultNeedUpload;
@synthesize resultUploader = _resultUploader;
@synthesize saveResultToAlbum = _saveResultToAlbum;

- (instancetype)initWithOperation:(SJCommonCodeClipsOperation)operation range:(CMTimeRange)range {
    self = [super init];
    if ( !self ) return nil;
    _operation = operation;
    _range = range;
    return self;
}
@end
