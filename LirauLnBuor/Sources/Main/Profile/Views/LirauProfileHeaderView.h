#import <UIKit/UIKit.h>
#import "LirauProfileModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauProfileHeaderView : UIView

@property (nonatomic, copy, nullable) void (^settingsHandler)(void);
@property (nonatomic, copy, nullable) void (^editHandler)(void);
@property (nonatomic, copy, nullable) void (^statHandler)(NSString *statName);

- (void)configureWithUser:(LirauProfileUser *)user;

@end

NS_ASSUME_NONNULL_END
