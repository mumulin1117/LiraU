#import <Foundation/Foundation.h>
#import "LirauProfileModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauProfileContentCompletion)(LirauProfileContent *content, NSError *_Nullable error, BOOL usedFallback, BOOL calledRemoteProfile);

@interface LirauProfileManager : NSObject

+ (instancetype)sharedManager;
- (void)loadProfileContentWithCompletion:(LirauProfileContentCompletion)completion;

@end

NS_ASSUME_NONNULL_END
