#import <UIKit/UIKit.h>
#import "LirauVideoSnippetLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauAudienceEngagementLorauaActionBarView : UIView

@property (nonatomic, copy, nullable) void (^audienceEngagementLorauaLikeHandler)(void);
@property (nonatomic, copy, nullable) void (^audienceEngagementLorauaCommentHandler)(void);

- (void)configureWithNarrativeSharingLorauaItem:(LirauVSnippetLorauaItem *)item;

@end

NS_ASSUME_NONNULL_END
