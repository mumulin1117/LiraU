#import <UIKit/UIKit.h>
#import "LirauHomeModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauHomeTalkShowCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^reportHandler)(void);

+ (NSString *)reuseIdentifier;
- (void)configureWithItem:(LirauHomeDynamicItem *)item highlightedCard:(BOOL)highlightedCard;

@end

NS_ASSUME_NONNULL_END
