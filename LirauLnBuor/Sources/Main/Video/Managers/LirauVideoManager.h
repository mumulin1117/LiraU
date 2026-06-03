#import <Foundation/Foundation.h>
#import "LirauVideoModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauVideoListCompletion)(NSArray<LirauVideoItem *> *items, NSError *_Nullable error, BOOL hasMore, BOOL usedFallback);

@interface LirauVideoManager : NSObject

+ (instancetype)sharedManager;
- (void)loadVideosWithCategory:(LirauVideoCategory)category
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    completion:(LirauVideoListCompletion)completion;

@end

NS_ASSUME_NONNULL_END
