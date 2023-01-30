//
//  SJCommonCodeResource+SJSubtitlesAdd.h
//  SJBaseCommonCode
//
//  Created by admin on 2019/11/8.
//

#import "SJCommonCodeResource.h"
#import "SJSubtitleItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJCommonCodeResource (SJSubtitlesAdd)
///
/// 未来将要显示的字幕
///
@property (nonatomic, copy, nullable) NSArray<SJSubtitleItem *> *subtitles;

@end

NS_ASSUME_NONNULL_END
