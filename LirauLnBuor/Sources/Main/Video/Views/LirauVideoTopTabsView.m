#import "LirauVideoTopTabsView.h"

@interface LirauVideoTopTabsView ()

@property (nonatomic, strong) UIStackView *tabStackView;
@property (nonatomic, strong) UIButton *hotButton;
@property (nonatomic, strong) UIButton *wowButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, assign) LirauVideoCategory selectedCategory;

@end

@implementation LirauVideoTopTabsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildView];
        [self selectCategory:LirauVideoCategoryHot];
    }
    return self;
}

- (void)buildView {
    self.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *tabBackground = [[UIView alloc] init];
    tabBackground.translatesAutoresizingMaskIntoConstraints = NO;
    tabBackground.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    tabBackground.layer.cornerRadius = 24;
    tabBackground.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner;
    tabBackground.clipsToBounds = YES;
    [self addSubview:tabBackground];

    self.tabStackView = [[UIStackView alloc] init];
    self.tabStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tabStackView.axis = UILayoutConstraintAxisHorizontal;
    self.tabStackView.distribution = UIStackViewDistributionFillEqually;
    [tabBackground addSubview:self.tabStackView];

    self.hotButton = [self makeTabButtonWithTitle:@"Hot" action:@selector(didTapHot)];
    self.wowButton = [self makeTabButtonWithTitle:@"Wow" action:@selector(didTapWow)];
    [self.tabStackView addArrangedSubview:self.hotButton];
    [self.tabStackView addArrangedSubview:self.wowButton];

    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.addButton.backgroundColor = UIColor.clearColor;
    self.addButton.layer.cornerRadius = 22;
    [self.addButton setImage:[UIImage imageNamed:@"lira_video_publish_add_button"] forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(didTapAdd) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.accessibilityLabel = @"LiraU video add";
    [self addSubview:self.addButton];

    [NSLayoutConstraint activateConstraints:@[
        [tabBackground.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [tabBackground.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [tabBackground.widthAnchor constraintEqualToConstant:200],
        [tabBackground.heightAnchor constraintEqualToConstant:47],
        [self.tabStackView.topAnchor constraintEqualToAnchor:tabBackground.topAnchor],
        [self.tabStackView.leadingAnchor constraintEqualToAnchor:tabBackground.leadingAnchor],
        [self.tabStackView.trailingAnchor constraintEqualToAnchor:tabBackground.trailingAnchor],
        [self.tabStackView.bottomAnchor constraintEqualToAnchor:tabBackground.bottomAnchor],
        [self.addButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.addButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.addButton.widthAnchor constraintEqualToConstant:44],
        [self.addButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (UIButton *)makeTabButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)selectCategory:(LirauVideoCategory)category {
    self.selectedCategory = category;
    [self updateButton:self.hotButton selected:category == LirauVideoCategoryHot];
    [self updateButton:self.wowButton selected:category == LirauVideoCategoryWow];
}

- (void)updateButton:(UIButton *)button selected:(BOOL)selected {
    if (selected) {
        button.backgroundColor = [UIColor colorWithRed:0.72 green:0.24 blue:1 alpha:1];
        button.layer.cornerRadius = 24;
        button.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMaxYCorner;
    } else {
        button.backgroundColor = UIColor.clearColor;
    }
}

- (void)didTapHot {
    [self selectCategory:LirauVideoCategoryHot];
    if (self.categoryChangedHandler) {
        self.categoryChangedHandler(LirauVideoCategoryHot);
    }
}

- (void)didTapWow {
    [self selectCategory:LirauVideoCategoryWow];
    if (self.categoryChangedHandler) {
        self.categoryChangedHandler(LirauVideoCategoryWow);
    }
}

- (void)didTapAdd {
    if (self.addHandler) {
        self.addHandler();
    }
}

@end
