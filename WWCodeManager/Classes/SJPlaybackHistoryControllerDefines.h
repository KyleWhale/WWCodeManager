//
//  SJPlaybackHistoryControllerDefines.h
//  Pods
//
//  Created by admin on 2020/2/19.
//

#ifndef SJPlaybackHistoryControllerDefines_h
#define SJPlaybackHistoryControllerDefines_h
#if __has_include(<SJUIKit/SJSQLite3.h>)
#import <SJUIKit/SJSQLite3+QueryExtended.h>
#else
#import "SJSQLite3+QueryExtended.h"
#endif

#import "SJCommonCodeResource.h"
@protocol SJPlaybackRecord;

NS_ASSUME_NONNULL_BEGIN

typedef NSString *SJMTType; // 目前存在两种类型, 分别是: `SJMTTypeVideo`(视频) 与 `SJMTTypeAudio`(音乐)
extern SJMTType const SJMTTypeVideo;
extern SJMTType const SJMTTypeAudio;

@protocol SJPlaybackHistoryController <NSObject>

///
/// 保存或更新播放记录
///
- (void)save:(id<SJPlaybackRecord>)record;

#pragma mark -

///
/// 查询, 如不存在将返回 nil
///
- (nullable id<SJPlaybackRecord>)recordForMedia:(NSInteger)mediaId user:(NSInteger)userId mediaType:(SJMTType)mediaType;

///
/// 查询
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForUser:(NSInteger)userId mediaType:(SJMTType)mediaType range:(NSRange)range;

///
/// 查询
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForUser:(NSInteger)userId mediaType:(SJMTType)mediaType;

///
/// 查询
///
/// \code
///    // 这个方法适合分页查询的场景, 当数据量过大时, 可以指定请求的range
///    // 根据指定的`用户id`以及`mediaType`进行查询, 并将结果排序(以更新的时间倒序排列), 返回满足条件的前20条数据
///    NSArray *records = [SJPlaybackHistoryController.shared recordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMTTypeVideo],
///    ] orderBy:@[
///        [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:NO]
///    ] range:NSMakeRange(0, 20)];
/// \endcode
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders range:(NSRange)range;

///
/// 查询
///
/// \code
///    // 根据指定的`用户id`以及`mediaType`进行查询, 并将结果排序(以更新的时间倒序排列), 返回满足条件的数据
///    NSArray *records = [SJPlaybackHistoryController.shared recordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMTTypeVideo],
///    ] orderBy:@[
///        [SJSQLite3ColumnOrder orderWithColumn:@"updatedTime" ascending:NO]
///    ]];
/// \endcode
///
- (nullable NSArray<id<SJPlaybackRecord>> *)recordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions orderBy:(nullable NSArray<SJSQLite3ColumnOrder *> *)orders;

#pragma mark -

///
/// 查询数量
///
- (NSUInteger)countOfRecordsForUser:(NSInteger)userId mediaType:(SJMTType)mediaType;

///
/// 查询数量
///
/// \code
///    // 根据指定的`用户id`以及`mediaType`进行查询
///    [SJPlaybackHistoryController.shared countOfRecordsForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMTTypeVideo],
///    ]];
/// \endcode
///
- (NSUInteger)countOfRecordsForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions;

#pragma mark -

///
/// 删除
///
- (void)remove:(NSInteger)media user:(NSInteger)userId mediaType:(SJMTType)mediaType;

///
/// 删除
///
- (void)removeAllRecordsForUser:(NSInteger)userId mediaType:(SJMTType)mediaType;

///
/// 删除
///
/// \code
///    [SJPlaybackHistoryController.shared removeForConditions:@[
///        [SJSQLite3Condition conditionWithColumn:@"userId" value:@(userId)],
///        [SJSQLite3Condition conditionWithColumn:@"mediaType" value:SJMTTypeVideo],
///    ]];
/// \endcode
///
- (void)removeForConditions:(nullable NSArray<SJSQLite3Condition *> *)conditions;
@end

@protocol SJPlaybackRecord <NSObject>
@property (nonatomic, readonly) NSInteger mediaId;
@property (nonatomic, readonly) NSInteger userId;
@property (nonatomic, readonly) SJMTType mediaType;
@property (nonatomic, readonly) NSTimeInterval position; ///< 上次观看到的位置
@property (nonatomic, readonly) NSTimeInterval createdTime;
@property (nonatomic, readonly) NSTimeInterval updatedTime;
@end
NS_ASSUME_NONNULL_END

#endif /* SJPlaybackHistoryControllerDefines_h */
