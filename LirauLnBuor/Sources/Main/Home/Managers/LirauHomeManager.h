#import <Foundation/Foundation.h>
#import "LirauHomeModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauHomeContentCompletion)(LirauHomeContent *content, NSError *_Nullable error, BOOL usedFallback);

@interface LirauHomeManager : NSObject

+ (instancetype)sharedManager;
- (void)loadHomeContentWithCompletion:(LirauHomeContentCompletion)completion;

@end

NS_ASSUME_NONNULL_END
