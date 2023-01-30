//
//  SJCommonCodeURLAsset+SJSubtitlesAdd.h
//  SJBaseCommonCode
//
//  Created by 畅三江 on 2019/11/8.
//

#import "SJCommonCodeURLAsset.h"
#import "SJSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJCommonCodeURLAsset (SJSubtitlesAdd)
///
/// 未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<SJSubtitleItem *> *subtitles;

@end

NS_ASSUME_NONNULL_END
