#import <UIKit/UIKit.h>
#import "LirauVideoModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauVideoCell : UICollectionViewCell

@property (nonatomic, copy, nullable) void (^likeHandler)(void);
@property (nonatomic, copy, nullable) void (^commentHandler)(void);
@property (nonatomic, copy, nullable) void (^giftHandler)(void);
@property (nonatomic, copy, nullable) void (^shareHandler)(void);
@property (nonatomic, copy, nullable) void (^userHandler)(void);
@property (nonatomic, copy, nullable) void (^videoHandler)(void);

+ (NSString *)reuseIdentifier;
- (void)configureWithItem:(LirauVideoItem *)item;

@end

NS_ASSUME_NONNULL_END
