#import "LirauVideoActionBarView.h"

@interface LirauVideoActionBarView ()

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *giftButton;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation LirauVideoActionBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
    }
    return self;
}

- (void)buildView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.spacing = 10;
    [self addSubview:stackView];

    self.likeButton = [self imageButtonWithBackground:@"lira_video_like_button" image:@"lira_video_like_icon" action:@selector(didTapLike)];
    self.commentButton = [self imageButtonWithBackground:@"lira_video_comment_button" image:@"lira_video_comment_icon" action:@selector(didTapComment)];
    self.giftButton = [self symbolButtonWithName:@"gift" action:@selector(didTapGift)];
    self.shareButton = [self symbolButtonWithName:@"square.and.arrow.up" action:@selector(didTapShare)];

    [stackView addArrangedSubview:self.likeButton];
    [stackView addArrangedSubview:self.commentButton];
    [stackView addArrangedSubview:self.giftButton];
    [stackView addArrangedSubview:self.shareButton];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.likeButton.widthAnchor constraintEqualToConstant:44],
        [self.likeButton.heightAnchor constraintEqualToConstant:44],
        [self.commentButton.widthAnchor constraintEqualToConstant:44],
        [self.commentButton.heightAnchor constraintEqualToConstant:44],
        [self.giftButton.widthAnchor constraintEqualToConstant:44],
        [self.giftButton.heightAnchor constraintEqualToConstant:44],
        [self.shareButton.widthAnchor constraintEqualToConstant:44],
        [self.shareButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (UIButton *)imageButtonWithBackground:(NSString *)background image:(NSString *)image action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)symbolButtonWithName:(NSString *)symbolName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.16];
    button.layer.cornerRadius = 22;
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightSemibold];
    UIImage *image = [[UIImage systemImageNamed:symbolName withConfiguration:configuration] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configureWithItem:(LirauVideoItem *)item {
    self.likeButton.selected = item.likedLocally;
    self.likeButton.alpha = item.likedLocally ? 1.0 : 0.82;
}

- (void)didTapLike {
    if (self.likeHandler) {
        self.likeHandler();
    }
}

- (void)didTapComment {
    if (self.commentHandler) {
        self.commentHandler();
    }
}

- (void)didTapGift {
    if (self.giftHandler) {
        self.giftHandler();
    }
}

- (void)didTapShare {
    if (self.shareHandler) {
        self.shareHandler();
    }
}

@end
