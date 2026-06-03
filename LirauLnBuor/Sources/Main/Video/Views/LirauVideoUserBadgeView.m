#import "LirauVideoUserBadgeView.h"

@interface LirauVideoUserBadgeView ()

@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation LirauVideoUserBadgeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.22];
    self.layer.cornerRadius = 20;
    self.clipsToBounds = YES;

    self.avatarView = [[UIView alloc] init];
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarView.backgroundColor = [UIColor colorWithWhite:0.86 alpha:1];
    self.avatarView.layer.cornerRadius = 20;
    [self addSubview:self.avatarView];

    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.nameLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:40],
        [self.avatarView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.avatarView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.avatarView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.avatarView.widthAnchor constraintEqualToConstant:40],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:12],
        [self.nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16],
        [self.nameLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

- (void)configureWithItem:(LirauVideoItem *)item {
    self.nameLabel.text = item.userName;
}

@end
