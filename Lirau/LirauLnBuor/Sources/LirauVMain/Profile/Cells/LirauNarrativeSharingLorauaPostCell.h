#import <UIKit/UIKit.h>
#import "LirauProfileIntroLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauNarrativeSharingLorauaPostCell : UICollectionViewCell

+ (NSString *)narrativeSharingLorauaReuseIdentifier;
- (void)configureWithNarrativeSharingLorauaPost:(LirauNarrativeSharingLorauaPost *)post;

@end

NS_ASSUME_NONNULL_END
