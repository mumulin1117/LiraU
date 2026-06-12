#import <Foundation/Foundation.h>
#import "LirauProfileIntroLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^LirauProfileIntroLorauaContentCompletion)(LirauProfileIntroLorauaContent *content, NSError *_Nullable error, BOOL usedFallback, BOOL calledRemoteProfile);

@interface LirauProfileIntroLorauaManager : NSObject

+ (instancetype)sharedProfileIntroLorauaManager;
- (void)loadProfileIntroLorauaContentWithCompletion:(LirauProfileIntroLorauaContentCompletion)completion;

@end

NS_ASSUME_NONNULL_END
