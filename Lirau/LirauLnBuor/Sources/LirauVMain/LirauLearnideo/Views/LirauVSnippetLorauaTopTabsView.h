#import <UIKit/UIKit.h>
#import "LirauVideoSnippetLorauaModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface LirauVSnippetLorauaTopTabsView : UIView

@property (nonatomic, copy, nullable) void (^videoSnippetLorauaCategoryChangedHandler)(LirauVideoSnippetLorauaCategory category);
@property (nonatomic, copy, nullable) void (^videoSnippetLorauaAddHandler)(void);

- (void)selectVideoSnippetLorauaCategory:(LirauVideoSnippetLorauaCategory)category;

@end

NS_ASSUME_NONNULL_END
