#import <UIKit/UIKit.h>
#import "LirauProfileIntroLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauProfileIntroLorauaHeaderView : UIView

@property (nonatomic, copy, nullable) void (^settingsHandler)(void);
@property (nonatomic, copy, nullable) void (^editHandler)(void);
@property (nonatomic, copy, nullable) void (^statHandler)(NSString *statName);

- (void)configureWithGlobalCitizenLorauaProfile:(LirauGlobalCitizenLorauaProfile *)profile;

@end

NS_ASSUME_NONNULL_END
