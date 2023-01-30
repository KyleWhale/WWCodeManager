//
//  SJPlaybackRecord.h
//  SJBaseCommonCode
//
//  Created by BlueDancer on 2020/5/25.
//

#import "SJPlaybackHistoryControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJPlaybackRecord : NSObject<SJPlaybackRecord>
- (instancetype)initWithMediaId:(NSInteger)mediaId mediaType:(SJMTType)mediaType userId:(NSInteger)userId;
@property (nonatomic) NSInteger mediaId;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSTimeInterval position;
@property (nonatomic) SJMTType mediaType;
@end


@interface SJPlaybackRecord (SJPrivate)
@property (nonatomic) NSInteger id;
@property (nonatomic) NSTimeInterval createdTime;
@property (nonatomic) NSTimeInterval updatedTime;
@end
NS_ASSUME_NONNULL_END
