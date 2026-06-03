#import <UIKit/UIKit.h>
#import "LirauHomeModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauHomeWordBitsCell : UICollectionViewCell

+ (NSString *)reuseIdentifier;
- (void)configureWithItem:(LirauHomeDynamicItem *)item;

@end

NS_ASSUME_NONNULL_END
