#import "LirauHomeSectionTitleView.h"

@interface LirauHomeSectionTitleView ()

@property (nonatomic, copy) NSString *imageName;

@end

@implementation LirauHomeSectionTitleView

- (instancetype)initWithImageName:(NSString *)imageName {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _imageName = [imageName copy];
        [self buildView];
    }
    return self;
}

- (void)buildView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageName]];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];

    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [imageView.widthAnchor constraintEqualToConstant:113],
        [imageView.heightAnchor constraintEqualToConstant:32]
    ]];
}

@end
