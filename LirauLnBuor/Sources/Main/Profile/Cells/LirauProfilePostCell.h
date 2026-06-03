#import <UIKit/UIKit.h>
#import "LirauProfileModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauProfilePostCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;
- (void)configureWithPost:(LirauProfilePost *)post;

@end

NS_ASSUME_NONNULL_END
