#import "LirauProfileIntroLorauaEmptyView.h"

@interface LirauProfileIntroLorauaEmptyView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LirauProfileIntroLorauaEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
        self.layer.cornerRadius = 20;

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.numberOfLines = 0;
        [self addSubview:self.titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.heightAnchor constraintGreaterThanOrEqualToConstant:132],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:24],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-24],
            [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
        ]];
    }
    return self;
}

- (void)configureWithProfileIntroLorauaText:(NSString *)text {
    self.titleLabel.text = text;
}

@end
