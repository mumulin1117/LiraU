#import <UIKit/UIKit.h>
#import "LirauVideoModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauVideoTopTabsView : UIView

@property (nonatomic, copy, nullable) void (^categoryChangedHandler)(LirauVideoCategory category);
@property (nonatomic, copy, nullable) void (^addHandler)(void);

- (void)selectCategory:(LirauVideoCategory)category;

@end

NS_ASSUME_NONNULL_END
