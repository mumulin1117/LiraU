#import <UIKit/UIKit.h>
#import "LirauVideoSnippetLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauVSnippetLorauaCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^audienceEngagementLorauaLikeHandler)(void);
@property (nonatomic, copy, nullable) void (^audienceEngagementLorauaCommentHandler)(void);
@property (nonatomic, copy, nullable) void (^reportSystemLorauaHandler)(void);
@property (nonatomic, copy, nullable) void (^languageExchangePartnerLorauaHandler)(void);
@property (nonatomic, copy, nullable) void (^videoSnippetLorauaHandler)(void);

+ (NSString *)videoSnippetLorauaReuseIdentifier;
- (void)configureWithNarrativeSharingLorauaItem:(LirauVSnippetLorauaItem *)item;

@end

NS_ASSUME_NONNULL_END
