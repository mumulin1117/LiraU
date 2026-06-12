#import <UIKit/UIKit.h>
#import "LirauDiscoveryFeedLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauVocabularyBuilderLorauaCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^reportSystemLorauaHandler)(void);

+ (NSString *)reuseIdentifier;
- (void)configureWithNarrativeSharingLorauaItem:(LirauNarrativeSharingLorauaDynamicItem *)item;

@end

NS_ASSUME_NONNULL_END
