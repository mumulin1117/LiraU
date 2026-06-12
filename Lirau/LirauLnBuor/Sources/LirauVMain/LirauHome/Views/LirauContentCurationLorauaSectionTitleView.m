#import "LirauContentCurationLorauaSectionTitleView.h"

@interface LirauContentCurationLorauaSectionTitleView ()

@property (nonatomic, copy) NSString *imageName;

@end

@implementation LirauContentCurationLorauaSectionTitleView

- (instancetype)initWithImageName:(NSString *)imageName {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _imageName = [imageName copy];
        [self buildDiscoveryFeedLorauaView];
    }
    return self;
}

- (void)buildDiscoveryFeedLorauaView {
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
