#import <UIKit/UIKit.h>
#import "LirauDiscoveryFeedLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauNarrativeSharingLorauaCardCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^reportSystemLorauaHandler)(void);

+ (NSString *)reuseIdentifier;
- (void)configureWithNarrativeSharingLorauaItem:(LirauNarrativeSharingLorauaDynamicItem *)item highlightedCard:(BOOL)highlightedCard;

@end

NS_ASSUME_NONNULL_END
