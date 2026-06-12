#import <Foundation/Foundation.h>
#import "LirauVideoSnippetLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauVideoSnippetLorauaListCompletion)(NSArray<LirauVSnippetLorauaItem *> *items, NSError *_Nullable error, BOOL hasMore, BOOL usedFallback);

@interface LirauVSnippetLorauaManager : NSObject

+ (instancetype)sharedVideoSnippetLorauaManager;
- (void)loadVideoSnippetLorauaItemsWithCategory:(LirauVideoSnippetLorauaCategory)category
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize
                    completion:(LirauVideoSnippetLorauaListCompletion)completion;

@end

NS_ASSUME_NONNULL_END
