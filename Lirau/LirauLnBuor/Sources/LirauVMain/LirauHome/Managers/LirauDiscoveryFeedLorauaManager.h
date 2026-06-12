#import <Foundation/Foundation.h>
#import "LirauDiscoveryFeedLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauDiscoveryFeedLorauaContentCompletion)(LirauDiscoveryFeedLorauaContent *content, NSError *_Nullable error, BOOL usedFallback);

@interface LirauDiscoveryFeedLorauaManager : NSObject

+ (instancetype)sharedDiscoveryFeedLorauaManager;
- (void)loadDiscoveryFeedLorauaContentWithCompletion:(LirauDiscoveryFeedLorauaContentCompletion)completion;

@end

NS_ASSUME_NONNULL_END
