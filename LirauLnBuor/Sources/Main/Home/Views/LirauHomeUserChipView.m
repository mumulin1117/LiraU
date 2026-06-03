#import "LirauHomeUserChipView.h"

@interface LirauHomeUserChipView ()

@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation LirauHomeUserChipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.12];
    self.layer.cornerRadius = 20;
    self.clipsToBounds = YES;

    _avatarView = [[UIView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor colorWithRed:0.79 green:0.48 blue:1 alpha:1];
    _avatarView.layer.cornerRadius = 16;
    _avatarView.clipsToBounds = YES;
    [self addSubview:_avatarView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_nameLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:40],
        [_avatarView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
        [_avatarView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_avatarView.widthAnchor constraintEqualToConstant:32],
        [_avatarView.heightAnchor constraintEqualToConstant:32],
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarView.trailingAnchor constant:8],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [_nameLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

- (void)configureWithRecommendation:(LirauHomeUserRecommendation *)recommendation {
    self.nameLabel.text = recommendation.name;
}

@end
