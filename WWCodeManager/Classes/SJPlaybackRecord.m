//
//  SJPlaybackRecord.m
//  SJBaseCommonCode
//
//  Created by BlueDancer on 2020/5/25.
//

#import "SJPlaybackRecord.h"

@interface SJPlaybackRecord ()
@property (nonatomic) NSInteger id;
@property (nonatomic) NSTimeInterval createdTime;
@property (nonatomic) NSTimeInterval updatedTime;
@end

@implementation SJPlaybackRecord
- (instancetype)initWithMediaId:(NSInteger)mediaId mediaType:(SJMTType)mediaType userId:(NSInteger)userId {
    self = [self init];
    if ( self ) {
        _mediaId = mediaId;
        _mediaType = mediaType;
        _userId = userId;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _mediaType = SJMTTypeVideo;
    }
    return self;
}
@end
