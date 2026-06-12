#import "LirauHomeUserChipView.h"

@interface LirauHomeUserChipView ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) NSString *currentAvatarURLString;

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

    _avatarImageView = [[UIImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarImageView.backgroundColor = [UIColor colorWithRed:0.79 green:0.48 blue:1 alpha:1];
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.image = [UIImage imageNamed:@"lira_profile_avatar_default"];
    _avatarImageView.layer.cornerRadius = 16;
    _avatarImageView.clipsToBounds = YES;
    [self addSubview:_avatarImageView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _nameLabel.textColor = UIColor.whiteColor;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_nameLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.heightAnchor constraintEqualToConstant:40],
        [_avatarImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
        [_avatarImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_avatarImageView.widthAnchor constraintEqualToConstant:32],
        [_avatarImageView.heightAnchor constraintEqualToConstant:32],
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_avatarImageView.trailingAnchor constant:8],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [_nameLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
}

- (void)configureWithRecommendation:(LirauHomeUserRecommendation *)recommendation {
    self.nameLabel.text = recommendation.name;
    self.currentAvatarURLString = recommendation.avatarURLString ?: @"";
    self.avatarImageView.image = [UIImage imageNamed:@"lira_profile_avatar_default"];
    [self loadAvatarFromURLString:self.currentAvatarURLString];
}

- (void)loadAvatarFromURLString:(NSString *)urlString {
    UIImage *fallbackImage = [UIImage imageNamed:@"lira_profile_avatar_default"];
    NSString *trimmedURLString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedURLString.length == 0) {
        self.avatarImageView.image = fallbackImage;
        return;
    }

    UIImage *assetImage = [UIImage imageNamed:trimmedURLString];
    if (assetImage) {
        self.avatarImageView.image = assetImage;
        return;
    }

    if ([trimmedURLString hasPrefix:@"//"]) {
        trimmedURLString = [@"http:" stringByAppendingString:trimmedURLString];
    } else if ([trimmedURLString hasPrefix:@"www."]) {
        trimmedURLString = [@"http://" stringByAppendingString:trimmedURLString];
    }

    NSURL *url = [NSURL URLWithString:trimmedURLString];
    if (!url) {
        NSString *encodedURLString = [trimmedURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:encodedURLString];
    }
    if (!url) {
        self.avatarImageView.image = fallbackImage;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = nil;
        if (!error && data.length > 0) {
            image = [UIImage imageWithData:data];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || ![strongSelf.currentAvatarURLString isEqualToString:urlString]) {
                return;
            }
            strongSelf.avatarImageView.image = image ?: fallbackImage;
        });
    }] resume];
}

@end
